//
//  NUInAppMsgUIManager.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMsgViewSettings.h"
#import "NUInAppMessageUIView.h"
#import "NUInAppMsgWrapper.h"

@interface InAppMsgUIManager : NSObject<InAppMsgInteractionListener>

-(void) sendToQueue:(NSString*) iamId;
-(InAppMsgViewSettings*) viewSettings;

@end
