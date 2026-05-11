//
//  PhoneNumberBridge.mm
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 11.05.2026.
//

#import "PhoneNumberBridge.h"

#include <phonenumbers/phonenumberutil.h>

using i18n::phonenumbers::PhoneNumberUtil;
using i18n::phonenumbers::PhoneNumber;

@implementation PhoneNumberBridge

- (BOOL)isValidNumber:(NSString *)number
           regionCode:(NSString *)regionCode {
    PhoneNumber parsed;
    auto util = PhoneNumberUtil::GetInstance();

    auto result = util->Parse(
        [number UTF8String],
        [regionCode UTF8String],
        &parsed
    );

    if (result != PhoneNumberUtil::NO_PARSING_ERROR) {
        return NO;
    }

    return util->IsValidNumber(parsed);
}

- (nullable NSString *)formatE164:(NSString *)number
                       regionCode:(NSString *)regionCode {
    PhoneNumber parsed;
    auto util = PhoneNumberUtil::GetInstance();

    auto result = util->Parse(
        [number UTF8String],
        [regionCode UTF8String],
        &parsed
    );

    if (result != PhoneNumberUtil::NO_PARSING_ERROR) {
        return nil;
    }

    std::string formatted;
    util->Format(parsed, PhoneNumberUtil::E164, &formatted);

    return [NSString stringWithUTF8String:formatted.c_str()];
}

@end
