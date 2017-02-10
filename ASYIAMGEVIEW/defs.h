//
//  defs.h
//  PokeWar
//
//  Created by Alexander on 9/3/14.
//  Copyright (c) 2014 SDI. All rights reserved.
//

#ifndef Casting_defs_h
#define Casting_defs_h


#define trim(x) [x stringByTrimmingCharactersInSet:WSset]
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define SetSInt(x) [NSString stringWithFormat:@"%d",x]
#define SetInt(x) [NSString stringWithFormat:@"%ld",x]
#else
#define SetSInt(x) [NSString stringWithFormat:@"%d",x]
#define SetInt(x) SetSInt(x)
#endif

#define DQ_  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define _DQ });
#define MQ_ dispatch_async( dispatch_get_main_queue(), ^(void) {
#define _MQ });

#define MAIN_FRAME [[UIScreen mainScreen]bounds]
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height

#define fontLight(x)  [UIFont fontWithName:@"Raleway-Light" size:x];
#define fontRegular(x)  [UIFont fontWithName:@"Raleway-Regular" size:x];
#define fontMedium(x)  [UIFont fontWithName:@"Raleway-Medium" size:x];

#define EMAIL           @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@-"
#define PASSWORD_CHAR   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890._-*@!"
#define USERNAME    @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_- "
#define GROUPNAME    @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-,!@#$%^&*(){}[]|\/?':;.<>"

#define  NUMBERS @"0123456789+"
#define  NUMBERS1 @"0123456789"

#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

//LOCAL URLS
// http://114.69.235.57:5582/

#define OPENTABLE_URL @"http://mobile.opentable.com/opentable/?restId="

////Demo URL
////
//
//#define PROFILE_IMG_URL @"http://114.69.235.57:5582/Content/UsersImages/"
//#define WEBSERVICE_URL @"http://114.69.235.57:5582/Api/User/"
//#define WEBSERVICE_REST_URL @"http://114.69.235.57:5582/Api/Restaurant/"
//#define RESTAURANT_IMG_URL @"http://114.69.235.57:5582/Content/RestaurantImages/"
//#define GALLERY_IMG_URL @"http://114.69.235.57:5582/Content/RestaurantGallery/"
//#define Home_IMG_URL @"http://114.69.235.57:5582/Content/HomePageImages/"


//Development URL
#define PROFILE_IMG_URL @"http://114.69.235.57:5581/Content/UsersImages/"
#define WEBSERVICE_URL @"http://114.69.235.57:5581/Api/User/"
#define WEBSERVICE_REST_URL @"http://114.69.235.57:5581/Api/Restaurant/"
#define RESTAURANT_IMG_URL @"http://114.69.235.57:5581/Content/RestaurantImages/"
#define GALLERY_IMG_URL @"http://114.69.235.57:5581/Content/RestaurantGallery/"
#define Home_IMG_URL @"http://114.69.235.57:5581/Content/HomePageImages/"


//http://114.69.235.57:5583/Content/HomePageImages

//Local URL
////
//#define PROFILE_IMG_URL @"http://114.69.235.57:5583/Content/UsersImages/"
//#define WEBSERVICE_URL @"http://114.69.235.57:5583/Api/User/"
//#define WEBSERVICE_REST_URL @"http://114.69.235.57:5583/Api/Restaurant/"
//#define RESTAURANT_IMG_URL @"http://114.69.235.57:5583/Content/RestaurantImages/"
//#define GALLERY_IMG_URL @"http://114.69.235.57:5583/Content/RestaurantGallery/"
//#define Home_IMG_URL @"http://114.69.235.57:5583/Content/HomePageImages/"


#define SIGNUP_URL @"http://114.69.235.57:5583/Api/User/MobileSignup"
#define FORGOTPASS_URL @"http://114.69.235.57:5583/Api/User/MobileForgotPassword"
#define LOGIN_URL @"http://114.69.235.57:5583/Api/User/MobileLogin"

#define GOOGLE_DIRECTION_URL @"https://maps.googleapis.com/maps/api/directions/json?"

//Google Location URL

#define GOOGLE_LOC_URL @"http://maps.google.com/maps/api/geocode/json?sensor=false&address="
#define Currency_URL @"https://currency-api.appspot.com/api/USD/"
#define Country_URL @"http://restcountries.eu/rest/"


#endif
