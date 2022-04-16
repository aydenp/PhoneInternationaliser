//
//  CNPhoneNumber+ThingsThatArePrivateForSomeReason.h
//  PhoneInternationaliser
//
//  Created by Ayden Panhuyzen on 2022-04-16.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNPhoneNumber (ThingsThatArePrivateForSomeReason)
@property (nonatomic, readonly, copy) NSString *countryCode;
@property (nonatomic, readonly, copy) NSString *digits;
+ (instancetype)phoneNumberWithDigits:(NSString *)digits countryCode:(NSString *)countryCode;
+ (NSString *)dialingCodeForISOCountryCode:(NSString *)countryCode;
- (NSString *)digitsRemovingDialingCode;
- (NSString *)formattedStringValue;
@end

NS_ASSUME_NONNULL_END
