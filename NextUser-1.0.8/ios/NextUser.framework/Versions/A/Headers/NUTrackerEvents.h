//
//  NUTrackerEvents.h
//  NextUser
//
//  Created by Adrian Lazea on 17/10/2017.
//

#ifndef NUTrackerEvents_h
#define NUTrackerEvents_h

typedef NS_ENUM(NSUInteger, NUTrackerEvent) {
    SESSION_INITIALIZATION = 1,
    TRACK_ACTION = 3,
    TRACK_SCREEN = 4,
    TRACK_PURCHASE = 5,
    TRACK_USER = 8,
    TRACK_USER_VARIABLES = 9
};

#endif /* NUTrackerEvents_h */
