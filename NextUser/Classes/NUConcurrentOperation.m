//
//  NUOperation.m
//  Pods
//
//  Created by Adrian Lazea on 17/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUConcurrentOperation.h"

#import "NSError+NextUser.h"
#import "NUDDLog.h"


@implementation NUConcurrentOperation

- (NUTaskType) taskType {
    return _taskType;
}

-(id)init
{
    if (self = [super init])
    {
        executing = NO;
        finished = NO;
    }
    return self;
}

-(void)start
{
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)main
{
    @try {
        _responseInstance = [self execute];
    }
    @catch (NSException *exception) {
        DDLogInfo(@"NUOperation Exception: %@",[exception description]);
    }
    @finally {
        [self completeOperation];
    }
}

-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return executing;
}

-(BOOL)isFinished
{
    return finished;
}

-(id<NUTaskResponse>) execute
{
    return nil;
}

- (id<NUTaskResponse>) response
{
    return _responseInstance;
}

-(void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
