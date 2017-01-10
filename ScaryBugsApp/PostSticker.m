//
//  PostSticker.m
//  ScaryBugsApp
//
//  Created by kelly on 2017. 1. 9..
//  Copyright © 2017년 Ray Wenderlich. All rights reserved.
//

#import "PostSticker.h"
#import "AFAppDotNetAPIClient.h"

@implementation PostSticker

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stickerPackSeq = (NSUInteger)[[attributes valueForKeyPath:@"stickerPackSeq"] integerValue];
    self.stickerPackId = [attributes valueForKeyPath:@"stickerPackId"];
    self.stickerId = [attributes valueForKeyPath:@"stickerId"];
    self.thumbnail = [attributes valueForKeyPath:@"thumbnail"];
    self.exposeIos = [[attributes valueForKeyPath:@"exposeIos"] boolValue];
    self.stickerType = (PostStickerType)[[attributes valueForKeyPath:@"stickerType"] integerValue];
    self.registeredDatetime = [attributes valueForKeyPath:@"registeredDatetime"];
    self.sortOrder = (NSInteger)[[attributes valueForKeyPath:@"sortOrder"] integerValue];
    
    return self;
}

#pragma mark -

+ (NSURLSessionDataTask *)globalTimelinePostsWithBlock:(NSInteger)stickerPackSeq stickerPackId:(NSString *)stickerPackId block:(void (^)(NSArray *postStickers, NSError *error))block
{
    NSString *url = [NSString stringWithFormat:@"deco/item/list?stickerPackSeq=%zd", stickerPackSeq];
    return [[AFAppDotNetAPIClient sharedClient] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"result.stickerList"];
        if (!postsFromResponse || [postsFromResponse count] == 0) {
            if (block) {
                block([NSArray array], nil);
            }
            return;
        }
        
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        for (NSDictionary *attributes in postsFromResponse) {
            PostSticker *postSticker = [[PostSticker alloc] initWithAttributes:attributes];
            [postSticker setStickerPackId:stickerPackId];
            if (postSticker.exposeIos) {
                [mutablePosts addObject:postSticker];
            }
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}


@end
