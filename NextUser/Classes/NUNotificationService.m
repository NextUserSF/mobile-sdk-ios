#import "NUNotificationService.h"
#import "NUDDLog.h"

@interface NUNotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NUNotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSString *nuPicUrl = [self.bestAttemptContent userInfo][@"big_pic_url"];
    if (nuPicUrl != nil) {
        NSError *error = nil;
        UNNotificationAttachment *attachment = [UNNotificationAttachment
                                                attachmentWithIdentifier: [self.bestAttemptContent userInfo][@"identifier"]
                                                URL: [self.bestAttemptContent userInfo][@"big_pic_url"]
                                                options: nil
                                                error: &error];
        
        if (error == nil) {
            self.bestAttemptContent.attachments = [NSArray arrayWithObject:attachment];
        } else {
            DDLogInfo(@"Error on fetching notification picture %@", error);
        }
    }
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
