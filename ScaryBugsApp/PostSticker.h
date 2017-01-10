//
//  PostSticker.h
//  ScaryBugsApp
//
//  Created by kelly on 2017. 1. 9..
//  Copyright © 2017년 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>

typedef enum PostStickerType {
    PostStickerTypeEmoji,
    PostStickerTypeImage = 101,
    PostStickerTypeBubble = 102,
} PostStickerType;

@protocol PostSticker <NSObject>

@end

@interface PostSticker : JSONModel

@property (nonatomic) NSUInteger stickerPackSeq;
@property (nonatomic, strong) NSString *stickerPackId;
@property (nonatomic, strong) NSString *stickerId;

@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic) BOOL exposeIos;

@property (nonatomic) PostStickerType stickerType;
@property (nonatomic, strong) NSDate *registeredDatetime;
@property (nonatomic) NSInteger sortOrder;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+ (NSURLSessionDataTask *)globalTimelinePostsWithBlock:(NSInteger)stickerPackSeq stickerPackId:(NSString *)stickerPackId block:(void (^)(NSArray *postStickers, NSError *error))block;
@end
