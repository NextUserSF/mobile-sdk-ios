//
//  NULogLevel.h
//  Pods
//
//  Created by Adrian Lazea on 10/05/2017.
//
//

#ifndef NULogLevel_h
#define NULogLevel_h

typedef NS_ENUM(NSUInteger, NULogLevel) {
    /**
     *  Logging is turned off. No messages.
     */
    NULogLevelOff = 0,
    
    /**
     *  Logging of error messages only.
     */
    NULogLevelError = 1,
    
    /**
     *  Logging od error and warning messages.
     */
    NULogLevelWarning = 2,
    
    /**
     *  Logging of error, warning and info messages.
     */
    NULogLevelInfo = 3,
    
    /**
     *  Logging of error, warning, info and verbose messages.
     */
    NULogLevelVerbose = 4
};

#endif
