#import <Foundation/Foundation.h>
#import "NUConcurrentOperation.h"

#import "NUError.h"
#import "NUDDLog.h"
#import "NUTaskManager.h"

@implementation NUConcurrentOperation

-(id)init
{
    if (self = [super init]) {
        executing = NO;
        finished = NO;
    }
    
    return self;
}

-(void)start
{
    if ([self isCancelled]) {
        
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
        taskResponse = [self execute:[self responseInstance]];
    }
    @catch (NSException *exception) {
        DDLogInfo(@"NUOperation Exception: %@",[exception description]);
        [self onExecutionException:exception];
    }
    @finally {
        [self completeOperation];
        [[NUTaskManager manager] dispatchCompletionNotification:taskResponse];
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

-(void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (id<NUTaskResponse>) responseInstance
{
    return [[NUConcurrentOperationResponse alloc] initWithType:TASK_NO_TYPE shouldNotifyListeners:NO];
}

//overrride
- (id<NUTaskResponse>) execute:(id<NUTaskResponse>) responseInstance
{
    return responseInstance;
}

//overrride
- (id<NUTaskResponse>) getTaskResponse
{
    return taskResponse;
}

//overrride
-(void)onExecutionException:(NSException *) exception
{
    
}

@end


@implementation NUConcurrentOperationResponse

-(instancetype)initWithType:(NUTaskType) type shouldNotifyListeners:(BOOL) notify
{
    if (self = [super init]) {
        taskType = type;
        notifyListeners = notify;
    }
    
    return self;
}

- (NUTaskType) taskType
{
    return taskType;
}

- (BOOL) notifyListeners
{
    return notifyListeners;
}

- (BOOL) successfull
{
    return _success;
}

-(void)setSuccessfull:(BOOL) success
{
    _success = success;
}

@end
