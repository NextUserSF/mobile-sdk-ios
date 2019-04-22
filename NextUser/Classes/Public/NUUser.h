#import <Foundation/Foundation.h>
#import "NUUserVariables.h"

typedef NS_ENUM(NSUInteger, NUUserGender) {
    MALE = 0,
    FEMALE = 1
};

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
@property (nonatomic) NSString *customerID;

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
@property (nonatomic) NUUserGender gender;

/**
 *  User Variables.
 */
@property (nonatomic) NUUserVariables *nuUserVariables;

@end
