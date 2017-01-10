//
//  StringUtils.m
//  NHNCalendar
//
//  Created by kelly on 12. 9. 4..
//  Copyright (c) 2012년 NHN. All rights reserved.
//

#import "StringUtils.h"
#import "CommonUtil.h"

@implementation StringUtils

+ (BOOL)isEmpty:(NSString *)str
{
    if (str == nil) {
        return YES;
    }

    if ([str length] == 0) {
        return YES;
    }

    return NO;
}

+ (BOOL)isBlank:(NSString *)str
{
    if (str == nil) {
        return YES;
    }

    if ([str length] == 0) {
        return YES;
    }

    if ([[StringUtils trim:str] length] == 0) {
        return YES;
    }

    return NO;
}

+ (BOOL)isNotEmpty:(NSString *)str
{
    return NO == [StringUtils isEmpty:str];
}

+ (BOOL)isNotBlank:(NSString *)str
{
    return NO == [StringUtils isBlank:str];
}

+ (NSString *)collectionToCommaDelimitedString:(NSArray *)numberList
{
    if ([CommonUtil isEmptyList:numberList]) {
        return nil;
    }

    NSMutableString *builder = [NSMutableString string];
    for (NSNumber *number in numberList) {
        if (nil == number) {
            continue;
        }

        [builder appendString:[number stringValue]];
        [builder appendString:@","];
    }
    return [builder substringToIndex:[builder length] - 1];
}

+ (BOOL)isNumber:(NSString *)value
{
    if ([StringUtils isBlank:value]) {
        return NO;
    }

    return [StringUtils matches:value pattern:@"^\\d+$"];
}

+ (BOOL)matches:(NSString *)value pattern:(NSString *)pattern
{
    if ([StringUtils isEmpty:value]) {
        return NO;
    }

    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                                       options:NSRegularExpressionCaseInsensitive
                                                         error:&error];
    NSArray *matches = [regex matchesInString:value options:0 range:NSMakeRange(0, [value length])];

    return [CommonUtil isNotEmptyList:matches];
}

+ (NSInteger)cvtInt:(NSString *)str defaultValue:(NSInteger)defaultValue
{
    if ([StringUtils isEmpty:str]) {
        return defaultValue;
    }

    return [str integerValue];
}

+ (BOOL)equals:(NSString *)str1 andString:(NSString *)str2
{
    if (str1 == str2) {
        return YES; // Either both the same String, or both null
    }

    if (str1 != nil) {
        if (str2 != nil) {
            return [str1 isEqualToString:str2];
        }
    }
    return NO;
}

+ (NSString *)trim:(NSString *)string
{
    NSString *trimedString = [string stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return trimedString;
}

+ (BOOL)contains:(NSString *)string keyword:(NSString *)keyword ignoreCase:(BOOL)ignoreCase
{
    if ([StringUtils isEmpty:string] || [StringUtils isEmpty:keyword]) {
        return NO;
    }

    if (ignoreCase) {
        return [string.lowercaseString rangeOfString:keyword.lowercaseString].location != NSNotFound;
    } else {
        return [string rangeOfString:keyword].location != NSNotFound;
    }
}

+ (BOOL)containsKor:(NSString *)string
{
    if ([StringUtils isEmpty:string]) {
        return NO;
    }

    for (NSInteger i = 0; i < string.length; i++) {
        NSInteger code = [string characterAtIndex:i];
        if (code >= 44032 && code <= 55203) {
            return YES;
        }
    }

    return NO;
}

+ (NSMutableDictionary *)parseQueryString:(NSURL *)url
{
    if (url == nil) {
        return nil;
    }

    NSString *query = [url query];
    NSArray *queryArray = [query componentsSeparatedByString:@"&"];
    if (queryArray == nil) {
        return nil;
    }

    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:11];

    for (NSString *pair in queryArray) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] != 2) {
            continue;
        }
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [map setObject:val forKey:key];
    }

    return map;
}

+ (NSString *)stringWithInteger:(NSInteger)integerValue currency:(BOOL)currency
{
    NSMutableString *string = [NSMutableString string];
    NSString *convertedString = [NSString stringWithFormat:@"%zd", integerValue];
    if (currency) {
        NSInteger insertedCount = 0;
        for (NSInteger i = [convertedString length] - 1; i >= 0; i--) {
            if (insertedCount == 3) {
                insertedCount = 0;
                [string insertString:@"," atIndex:0];
            }
            NSString *value = [convertedString substringWithRange:NSMakeRange(i, 1)];
            [string insertString:value atIndex:0];
            insertedCount++;
        }
    } else {
        [string appendString:convertedString];
    }
    return string;
}

+ (NSString *)notNilString:(NSString *)aString
{
    if (aString == nil) {
        return @"";
    }
    return aString;
}

+ (int32_t)hash:(NSString *)str
{
    if ([self isEmpty:str]) {
        return 0;
    }

    NSInteger count = [str length];
    int32_t hash = 0;

    for (int i = 0; i < count; ++i) {
        hash = 31 * hash + [str characterAtIndex:i];
    }

    return hash;
}

@end
