//
//  PostSticker.h
//  ScaryBugsApp
//
//  Created by kelly on 2017. 1. 9..
//  Copyright © 2017년 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostSticker : NSObject

@property (nonatomic) NSUInteger stickerPackSeq;
@property (nonatomic, strong) NSString *stickerId;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic) BOOL exposeIos;
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+ (NSURLSessionDataTask *)globalTimelinePostsWithBlock:(NSInteger)stickerPackSeq block:(void (^)(NSArray *postStickers, NSError *error))block;
@end
