cmake_minimum_required(VERSION 3.22)

project(PhoneNumberBridge LANGUAGES C CXX OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

add_library(PhoneNumberBridge STATIC
    PhoneNumberBridge.mm

    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/alternate_format.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/asyoutypeformatter.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/default_logger.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/lite_metadata.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/logger.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/metadata.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/phonenumbermatch.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/phonenumberutil.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/regex_based_matcher.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/regexp_cache.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/short_metadata.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/shortnumberinfo.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/stringutil.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/unicodestring.cc

    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/phonenumber.pb.cc
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/phonemetadata.pb.cc

    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src/phonenumbers/utf/rune.c
)

target_include_directories(PhoneNumberBridge PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${ROOT_DIR}/Vendor/libphonenumber/cpp/src
    ${PROTOBUF_INCLUDE_DIR}
    ${ABSEIL_INCLUDE_DIR}
)

target_link_directories(PhoneNumberBridge PUBLIC
    ${PROTOBUF_LIB_DIR}
    ${ABSEIL_LIB_DIR}
)

target_link_libraries(PhoneNumberBridge PUBLIC
    protobuf
)