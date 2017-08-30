//
//  NUInAppMsgUIManager.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMsgViewSettings.h"

@interface InAppMsgUIManager : NSObject

-(void) sendToQueue:(NSString*) iamId;
-(InAppMsgViewSettings*) viewSettings;

@end
