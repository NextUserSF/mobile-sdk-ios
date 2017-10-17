//
//  NSObject+NUUser.h
//  Pods
//
//  Created by Adrian Lazea on 28/04/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUUserVariables.h"

/**
 *  This class creates an user instance
 */
@interface NUUser : NSObject

/**
 *  Creates an instance of user.
 *
 *  @return Instance of NUUser object.
 */
+ (instancetype) user;


/**
 *  @return user identifier(email or id)
 */
- (NSString *)userIdentifier;

- (BOOL) hasVariable:(NSString *)variableName;

- (void) addVariable:(NSString *)name withValue:(NSString *)value;

#pragma mark - User Properties
/**
 * @name User Properties
 */

/**
 *  User Email.
 */
@property (nonatomic) NSString *email;

/**
 *  User Id(optional).
 */
@property (nonatomic) NSString *uid;

/**
 *  User Subscription.
 */
@property (nonatomic) NSString *subscription;

/**
 *  User First Name.
 */
@property (nonatomic) NSString *firstname;

/**
 *  User Last Name.
 */
@property (nonatomic) NSString *lastname;

/**
 *  User Birth Year.
 */
@property (nonatomic) NSString *birthyear;

/**
 *  User Country.
 */
@property (nonatomic) NSString *country;

/**
 *  User State.
 */
@property (nonatomic) NSString *state;

/**
 *  User Zipcode.
 */
@property (nonatomic) NSString *zipcode;

/**
 *  User Locale.
 */
@property (nonatomic) NSString *locale;

/**
 *  User Gender.
 */
@property (nonatomic) NSString *gender;

/**
 *  User Variables.
 */
@property (nonatomic) NUUserVariables *nuUserVariables;

@end
