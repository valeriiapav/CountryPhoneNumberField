//
//  NBPhoneNumber.h
//  libPhoneNumber
//
//  This file is also the SPM umbrella header for the NBPhoneNumber module.
//  All public headers must be imported here so they are visible to Swift importers.
//

#import <Foundation/Foundation.h>

// Public API surface exported by the module
#import "NBPhoneNumberDefines.h"
#import "NBPhoneNumberDesc.h"
#import "NBNumberFormat.h"
#import "NBPhoneMetaData.h"
#import "NBMetadataHelper.h"
#import "NSArray+NBAdditions.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumberUtil+ShortNumber.h"
#import "NBAsYouTypeFormatter.h"

@interface NBPhoneNumber : NSObject<NSCopying, NSCoding>

// from phonemetadata.pb.js
/* 1 */ @property(nonatomic, strong, readwrite) NSNumber *countryCode;
/* 2 */ @property(nonatomic, strong, readwrite) NSNumber *nationalNumber;
/* 3 */ @property(nonatomic, strong, readwrite) NSString *extension;
/* 4 */ @property(nonatomic, assign, readwrite) BOOL italianLeadingZero;
/* 8 */ @property(nonatomic, strong, readwrite) NSNumber *numberOfLeadingZeros;
/* 5 */ @property(nonatomic, strong, readwrite) NSString *rawInput;
/* 6 */ @property(nonatomic, strong, readwrite) NSNumber *countryCodeSource;
/* 7 */ @property(nonatomic, strong, readwrite) NSString *preferredDomesticCarrierCode;

- (void)clearCountryCodeSource;
- (NBECountryCodeSource)getCountryCodeSourceOrDefault;

@end
