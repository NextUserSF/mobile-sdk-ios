//
//  NUAppWakeUpManager.m
//  NextUserKit
//
//  Created by Dino on 3/2/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUAppWakeUpManager.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface NUAppWakeUpManager () <CLLocationManagerDelegate>

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation NUAppWakeUpManager

+ (instancetype)manager
{
    return [[NUAppWakeUpManager alloc] init];
}

- (instancetype)init
{
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        [self deserializeIsRunning];
        [self requestLocationUsageAuthorization];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunchingNotification:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
//        [CLLocationManager significantLocationChangeMonitoringAvailable];
//        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        [[UIApplication sharedApplication] openURL:settingsURL];

    }
    
    return self;
}

#pragma mark - Notifications

- (void)applicationDidFinishLaunchingNotification:(NSNotification *)notification
{
    if (notification.userInfo[UIApplicationLaunchOptionsLocationKey] && _isRunning) {
        // our significant location change did wake up app
        [self notifyDelegateOnWakeUp];
    }
}

#pragma mark -

- (void)start
{
    NSAssert([self.class isAppInBackground], @"Must be in background to start app wake up manager.");
    
    if ([self.class isAppInBackground] && [self.class areLocationServicesEnabled]) {
        if (!_isRunning) {
            [self doStart];
        }
    } else {
        NSLog(@"Wakeup manager can start only when app is in background and location services are enabled");
    }
}

- (void)stop
{
    if (_isRunning) {
        [self doStop];
    }
}

#pragma mark - Private

- (void)doStart
{
    NSLog(@"Start monitoring significant location changes");
    _isRunning = YES;
    [self serializeIsRunning];
    [_locationManager startMonitoringSignificantLocationChanges];
}

- (void)doStop
{
    NSLog(@"Stop monitoring significant location changes");
    _isRunning = NO;
    [self serializeIsRunning];
    [_locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark -

- (void)serializeIsRunning
{
    [[NSUserDefaults standardUserDefaults] setBool:_isRunning forKey:@"com.nextuser.wakeupmanager.isrunning"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deserializeIsRunning
{
    _isRunning = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.nextuser.wakeupmanager.isrunning"];
}

#pragma mark -

+ (BOOL)isAppInBackground
{
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

- (void)requestLocationUsageAuthorization
{
    // iOS8 and above only
    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
}

+ (BOOL)areLocationServicesEnabled
{
    BOOL enabled = NO;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        enabled = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
    } else {
        enabled = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
    }
    
    return enabled;
}

- (BOOL)shouldStartLocationServicesOnAuthorizationChange
{
    return _isRunning && [self.class areLocationServicesEnabled] && [self.class isAppInBackground];
}

#pragma mark - Background Task

- (void)startBackgroundTask
{
    if (_backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        NSLog(@"Start background task");
        _backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)stopBackgroundTask
{
    if (_backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        NSLog(@"Stop background task");
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Notify Delegate

- (void)notifyDelegateOnWakeUp
{
    if ([self.class isAppInBackground]) {
        [self startBackgroundTask];
        [_delegate appWakeUpManager:self didWakeUpAppInBackgroundWithTaskCompletion:^{
            [self stopBackgroundTask];
        }];
    } else {
        NSLog(@"not in background, will not notify");
    }
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"Location manager did update locations. Remaining time in background: %@",
          @([[UIApplication sharedApplication] backgroundTimeRemaining]));
    
    [self notifyDelegateOnWakeUp];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager did fail. Stop location services. Error: %@", error);
    
    [self doStop];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Location manager did change authorization status: %@ (Enabled: %@). WAM running: %@",
          @(status), @([self.class areLocationServicesEnabled]), @(_isRunning));
    
    if ([self shouldStartLocationServicesOnAuthorizationChange]) {
        [_locationManager startMonitoringSignificantLocationChanges];
    }
}

@end
