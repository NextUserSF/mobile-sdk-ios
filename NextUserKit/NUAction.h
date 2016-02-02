//
//  NUAction.h
//  NextUserKit
//
//  Created by NextUser on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class represents an action that user performed inside the application. Action can be anything from
 *  pressing a button or using of some particular item inside the application.
 *
 *  Each action, at minimum, has its actionName which uniquely describes it. It can also contain up to
 *  10 additional parameters.
 */
@interface NUAction : NSObject

#pragma mark - Action Factory
/**
 * @name Action Factory
 */

/**
 *  Creates an instance of NUAction.
 *
 *  After calling this method, you can optionally configure action with additional 10 parameters.
 *  See methods set{1-10}Parameter. All of them are optional.
 *
 *  @param actionName Name of the action
 *
 *  @return Instance of NUAction object
 *  @warning Throws an exception if action name is invalid (empty or nil).
 */
+ (instancetype)actionWithName:(NSString *)actionName;

#pragma mark - Action Properties
/**
 * @name Action Properties
 */

/**
 *  Name of the action.
 */
@property (nonatomic, readonly) NSString *actionName;

#pragma mark - Action parameters
/**
 * @name Action parameters
 */

/**
 *  Sets action's first parameter.
 *
 *  @param firstParameter Action's first parameter.
 */
- (void)setFirstParameter:(NSString *)firstParameter;

/**
 *  Sets action's second parameter.
 *
 *  @param secondParameter Action's second parameter.
 */
- (void)setSecondParameter:(NSString *)secondParameter;

/**
 *  Sets action's third parameter.
 *
 *  @param thirdParameter Action's third parameter.
 */
- (void)setThirdParameter:(NSString *)thirdParameter;

/**
 *  Sets action's fourth parameter.
 *
 *  @param fourthParameter Action's fourth parameter.
 */
- (void)setFourthParameter:(NSString *)fourthParameter;

/**
 *  Sets action's fifth parameter.
 *
 *  @param fifthParameter Action's fifth parameter.
 */
- (void)setFifthParameter:(NSString *)fifthParameter;

/**
 *  Sets action's sixth parameter.
 *
 *  @param sixthParameter Action's sixth parameter.
 */
- (void)setSixthParameter:(NSString *)sixthParameter;

/**
 *  Sets action's seventh parameter.
 *
 *  @param seventhParameter Action's seventh parameter.
 */
- (void)setSeventhParameter:(NSString *)seventhParameter;

/**
 *  Sets action's eight parameter.
 *
 *  @param eightParameter Action's eight parameter.
 */
- (void)setEightParameter:(NSString *)eightParameter;

/**
 *  Sets action's ninth parameter.
 *
 *  @param ninthParameter Action's ninth parameter.
 */
- (void)setNinthParameter:(NSString *)ninthParameter;

/**
 *  Sets action's tenth parameter.
 *
 *  @param tenthParameter Action's tenth parameter.
 */
- (void)setTenthParameter:(NSString *)tenthParameter;

@end
