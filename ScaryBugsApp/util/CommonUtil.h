//
//  CommonUtil.h
//  NHNCalendar
//
//  Created by kelly on 12. 9. 5..
//  Copyright (c) 2012년 NHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

+ (BOOL)isEmptyList:(NSArray *)list;
+ (BOOL)isNotEmptyList:(NSArray *)list;
+ (BOOL)isEmptySet:(NSSet *)set;
+ (BOOL)isNotEmptySet:(NSSet *)set;
+ (BOOL)isEmptyMap:(NSDictionary *)map;
+ (BOOL)isNotEmptyMap:(NSDictionary *)map;
+ (void)sleep:(NSInteger)millis;
+ (NSArray *)subList:(NSArray *)originList page:(NSInteger)page pageSize:(NSInteger)pageSize;
+ (NSArray *)refinedList:(NSArray *)items refineValue:(NSInteger)refineValue;
+ (id)getCastedObject:(Class)aClass object:(id)object;
+ (NSArray *)sortIntegers:(NSArray *)originList;

@end
