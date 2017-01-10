//
//  CommonUtil.m
//  NHNCalendar
//
//  Created by kelly on 12. 9. 5..
//  Copyright (c) 2012년 NHN. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

+ (BOOL)isEmptyList:(NSArray *)list
{
    return (list == nil || [list count] == 0);
}

+ (BOOL)isNotEmptyList:(NSArray *)list
{
    return ![CommonUtil isEmptyList:list];
}

+ (BOOL)isEmptySet:(NSSet *)set
{
    return (set == nil || [set count] == 0);
}

+ (BOOL)isNotEmptySet:(NSSet *)set
{
    return ![CommonUtil isEmptySet:set];
}

+ (BOOL)isEmptyMap:(NSDictionary *)map
{
    if (map == nil) {
        return YES;
    } else if ([CommonUtil isEmptyList:[map allKeys]]) {
        return YES;
    }

    return NO;
}

+ (BOOL)isNotEmptyMap:(NSDictionary *)map
{
    return ![CommonUtil isEmptyMap:map];
}

+ (void)sleep:(NSInteger)second
{
    [NSThread sleepForTimeInterval:second];
}

+ (NSArray *)subList:(NSArray *)originList page:(NSInteger)page pageSize:(NSInteger)pageSize
{
    NSInteger size = [originList count];
    NSInteger start = (page - 1) * pageSize;
    if (size <= start) {
        return @[];
    }
    NSRange range = NSMakeRange(start, MIN(size - start, pageSize));
    return [originList subarrayWithRange:range];
}

+ (NSArray *)refinedList:(NSArray *)items refineValue:(NSInteger)refineValue
{
    if ([CommonUtil isEmptyList:items]) {
        return nil;
    }

    NSMutableArray *addedItems = [NSMutableArray arrayWithArray:items];
    NSInteger emptyObject = (refineValue - (items.count % refineValue)) % refineValue;

    for (NSInteger i = 0; i < emptyObject; i++) {
        [addedItems addObject:[NSNull null]];
    }

    return addedItems;
}

+ (id)getCastedObject:(Class)aClass object:(id)object
{
    if (![object isKindOfClass:[aClass class]]) {
        return nil;
    }

    return (Class)object;
}

+ (NSArray *)sortIntegers:(NSArray *)originList
{
    NSArray *sortedIntegerList = [originList sortedArrayUsingComparator:^(id obj1, id obj2) {
                                      if ([obj1 integerValue] > [obj2 integerValue]) {
                                          return (NSComparisonResult)NSOrderedDescending;
                                      }

                                      if ([obj1 integerValue] < [obj2 integerValue]) {
                                          return (NSComparisonResult)NSOrderedAscending;
                                      }
                                      return (NSComparisonResult)NSOrderedSame;
                                  }];

    return sortedIntegerList;
}

@end
