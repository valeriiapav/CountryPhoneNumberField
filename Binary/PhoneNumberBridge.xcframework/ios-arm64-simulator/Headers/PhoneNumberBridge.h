//
//  PhoneNumberBridge.h
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 11.05.2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhoneNumberBridge : NSObject

- (BOOL)isValidNumber:(NSString *)number
           regionCode:(NSString *)regionCode;

- (nullable NSString *)formatE164:(NSString *)number
                       regionCode:(NSString *)regionCode;

- (nullable NSString *)regionCodeForNumber:(NSString *)number
                                regionCode:(NSString *)regionCode;

- (nullable NSString *)nationalNumberForNumber:(NSString *)number
                                    regionCode:(NSString *)regionCode;

- (BOOL)isFixedLineNumber:(NSString *)number
               regionCode:(NSString *)regionCode;

@end

NS_ASSUME_NONNULL_END
