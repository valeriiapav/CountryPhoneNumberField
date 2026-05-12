//
//  PhoneNumberBridge.mm
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 11.05.2026.
//

#import "PhoneNumberBridge.h"

#include <phonenumbers/phonenumberutil.h>

using i18n::phonenumbers::PhoneNumber;
using i18n::phonenumbers::PhoneNumberUtil;

@implementation PhoneNumberBridge

- (BOOL)isValidNumber:(NSString *)number
           regionCode:(NSString *)regionCode {
    PhoneNumber parsed;

    if (![self parseNumber:number regionCode:regionCode into:&parsed]) {
        return NO;
    }

    auto util = PhoneNumberUtil::GetInstance();
    return util->IsValidNumber(parsed);
}

- (nullable NSString *)formatE164:(NSString *)number
                       regionCode:(NSString *)regionCode {
    PhoneNumber parsed;

    if (![self parseNumber:number regionCode:regionCode into:&parsed]) {
        return nil;
    }

    std::string formatted;
    auto util = PhoneNumberUtil::GetInstance();
    util->Format(parsed, PhoneNumberUtil::E164, &formatted);

    return [NSString stringWithUTF8String:formatted.c_str()];
}

- (nullable NSString *)regionCodeForNumber:(NSString *)number
                                regionCode:(NSString *)regionCode {
    PhoneNumber parsed;

    if (![self parseNumber:number regionCode:regionCode into:&parsed]) {
        return nil;
    }

    std::string region;
    auto util = PhoneNumberUtil::GetInstance();
    util->GetRegionCodeForNumber(parsed, &region);

    if (region.empty()) {
        return nil;
    }

    return [NSString stringWithUTF8String:region.c_str()];
}

- (nullable NSString *)nationalNumberForNumber:(NSString *)number
                                    regionCode:(NSString *)regionCode {
    PhoneNumber parsed;

    if (![self parseNumber:number regionCode:regionCode into:&parsed]) {
        return nil;
    }

    std::string nationalNumber = std::to_string(parsed.national_number());

    if (parsed.italian_leading_zero()) {
        nationalNumber = "0" + nationalNumber;
    }

    return [NSString stringWithUTF8String:nationalNumber.c_str()];
}

- (BOOL)isFixedLineNumber:(NSString *)number
               regionCode:(NSString *)regionCode {
    PhoneNumber parsed;

    if (![self parseNumber:number regionCode:regionCode into:&parsed]) {
        return NO;
    }

    auto util = PhoneNumberUtil::GetInstance();
    auto type = util->GetNumberType(parsed);

    return type == PhoneNumberUtil::FIXED_LINE;
}

// MARK: - Private

- (BOOL)parseNumber:(NSString *)number
         regionCode:(NSString *)regionCode
               into:(PhoneNumber *)parsed {
    if (number.length == 0 || regionCode.length == 0) {
        return NO;
    }

    auto util = PhoneNumberUtil::GetInstance();

    auto result = util->Parse(
        [number UTF8String],
        [regionCode UTF8String],
        parsed
    );

    return result == PhoneNumberUtil::NO_PARSING_ERROR;
}

@end
