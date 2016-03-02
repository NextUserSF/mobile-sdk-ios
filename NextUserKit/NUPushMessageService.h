//
//  NUPushMessageService.h
//  NextUserKit
//
//  Created by Dino on 3/1/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUTrackerSession;

@protocol NUPushMessageServiceDelegate <NSObject>

- (void)messagesReceived:(NSArray *)messages;

@end


@interface NUPushMessageService : NSObject

- (id)initWithSession:(NUTrackerSession *)session; // subclassers should call this initializer

@property (nonatomic) id <NUPushMessageServiceDelegate> delegate;
@property (nonatomic, readonly) NUTrackerSession *session;

@end

@interface NUPushMessageService (Subclass)

- (void)startListening;
- (void)stopListening;
- (void)fetchMissedMessages;

@end
