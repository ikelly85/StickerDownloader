//
//  StringUtils.h
//  NHNCalendar
//
//  Created by kelly on 12. 9. 4..
//  Copyright (c) 2012년 NHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtils : NSObject

+ (BOOL)isEmpty:(NSString *)str;
+ (BOOL)isBlank:(NSString *)str;
+ (BOOL)isNotEmpty:(NSString *)str;
+ (BOOL)isNotBlank:(NSString *)str;
+ (NSString *)collectionToCommaDelimitedString:(NSArray *)numberList;
+ (NSInteger)cvtInt:(NSString *)str defaultValue:(NSInteger)defaultValue;
+ (BOOL)isNumber:(NSString *)value;
+ (BOOL)matches:(NSString *)value pattern:(NSString *)pattern;
+ (BOOL)equals:(NSString *)str1 andString:(NSString *)str2;
+ (NSString *)trim:(NSString *)string;
+ (BOOL)contains:(NSString *)string keyword:(NSString *)keyword ignoreCase:(BOOL)ignoreCase;
+ (BOOL)containsKor:(NSString *)string;
+ (NSMutableDictionary *)parseQueryString:(NSURL *)url;
+ (NSString *)stringWithInteger:(NSInteger)integerValue currency:(BOOL)currency;
+ (NSString *)notNilString:(NSString *)aString;
+ (int32_t)hash:(NSString *)str;
@end
