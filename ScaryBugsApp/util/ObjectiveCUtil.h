/*
 *  ObjCUtil.m
 *  NaverMap
 *
   //  Created by KJ KIM on 11. 7. 14..
 *  Copyright 2011 NHN Corp. All rights reserved.
 *
 */


#pragma mark making singleton class


#define SYNTHESIZE_SINGLETON_CLASS(aClassName, aAccessor) SYNTHESIZE_SINGLETON_CLASS_WITH_RETURNTYPE(aClassName, aClassName *, aAccessor)

#define SYNTHESIZE_SINGLETON_CLASS_WITH_RETURNTYPE(aClassName, aReturnType, aAccessor)  \
                                                                                        \
    static aClassName * aAccessor = nil;                                                     \
                                                                                        \
    + (aReturnType)aAccessor                                                                \
    {                                                                                       \
        if (nil != aAccessor) {                                                             \
            return aAccessor;                                                               \
        }                                                                                   \
                                                                                        \
        static dispatch_once_t predicate;                                                   \
        dispatch_once(&predicate, ^{                                                        \
            aAccessor = [[self alloc] init];                                                \
        });                                                                                 \
                                                                                        \
        return aAccessor;                                                                   \
    }                                                                                       \
                                                                                        \

