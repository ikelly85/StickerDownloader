//
//  BannerEventThumbnailWorker.m
//  chat
//
//  Created by kelly on 2015. 10. 22..
//  Copyright © 2015년 campmobile. All rights reserved.
//

#import "ThumbnailWorker.h"
#import "ObjectiveCUtil.h"
#import "CommonUtil.h"
#import "AppDelegate.h"
#import "Post.h"
#import "PostSticker.h"
#import "StringUtils.h"

@implementation ThumbnailWorker

SYNTHESIZE_SINGLETON_CLASS(ThumbnailWorker, sharedInstance);

- (NSString *)makePath:(NSString *)thumbnail index:(NSInteger)index
{
    NSString *targetId = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    if (index < [appDelegate.packDownloads count]) {
        Post *post = [appDelegate.packDownloads objectAtIndex:index];
        if ([StringUtils equals:post.thumbnailOn andString:thumbnail]) {
            targetId = post.stickerPackId;
        }
    }
    
    if (index < [appDelegate.itemDownloads count]) {
        PostSticker *post = [appDelegate.itemDownloads objectAtIndex:index];
        if ([StringUtils equals:post.thumbnail andString:thumbnail]) {
            targetId = post.stickerId;
        }
    }
    
    NSString *fileName = targetId;
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *fileNamePath = [NSString stringWithFormat:@"postSticker/images/%@.png", fileName];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileNamePath];

    return filePath;
}

- (BOOL)processJob
{
    if ([CommonUtil isNotEmptyMap:thumbnailUrlMap]) {
        return NO;
    }
    if (!session) {
        session = [self URLsession];
    }
    
    thumbnailUrlMap = [NSMutableDictionary dictionary];

    NSMutableArray *thumbnailList = [NSMutableArray array];
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    for (Post *post in appDelegate.packDownloads) {
        [thumbnailList addObject:post.thumbnailOn];
    }
    [self setThumbnailUrlMapOn:thumbnailList];
    
    [thumbnailList removeAllObjects];
    for (PostSticker *postSticker in appDelegate.itemDownloads) {
        [thumbnailList addObject:postSticker.thumbnail];
    }
    [self setThumbnailUrlMapOn:thumbnailList];
    
    if ([CommonUtil isEmptyMap:thumbnailUrlMap]) {
        return NO;
    }

    NSInteger i = 0;
    NSInteger totalCount = [thumbnailUrlMap count];
    @synchronized (thumbnailUrlMap) {
        for (NSString *thumbnailPath in[thumbnailUrlMap keyEnumerator]) {
            NSInteger index = [[thumbnailUrlMap objectForKey:thumbnailPath] integerValue];
            NSString *saveImagePath = [self makePath:thumbnailPath index:index];
            [self downloadURL:thumbnailPath toPath:saveImagePath isLast:(i == totalCount - 1) index:index];
            i++;
        }
        [thumbnailUrlMap removeAllObjects];
    }
    return NO;
}

- (void)setThumbnailUrlMapOn:(NSArray *)thumbnailList
{
    if ([CommonUtil isEmptyList:thumbnailList]) {
        return;
    }
    
    NSInteger i = 0;
    for (NSString *thumbnail in thumbnailList) {
        @synchronized (thumbnailUrlMap) {
            [thumbnailUrlMap setObject:@(i) forKey:thumbnail];
        }
        i++;
    }
}

- (NSURLSession *)URLsession
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    sessionConfig.timeoutIntervalForResource = 300;
    sessionConfig.timeoutIntervalForRequest = 300;
    sessionConfig.networkServiceType = NSURLNetworkServiceTypeBackground;
    NSURLSession *_session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    return _session;
}

- (NSProgress *)downloadURL:(NSString *)serverPath toPath:(NSString *)path isLast:(BOOL)isLast index:(NSInteger)index
{
    NSURL *url = nil;
    if ([serverPath hasPrefix:@"http"]) {
        url = [NSURL URLWithString:serverPath];
    } else {
        NSString *baseServerPath = @"http://dev-gw.snow.me";
        url = [NSURL URLWithString:[baseServerPath stringByAppendingPathComponent:serverPath]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSProgress *progress;
    NSURLSessionDownloadTask *downloadTask;

    downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                        if (error) {
                            [self onFailureImage:error];
                        } else {
                            [self onSucceessImage:[location path] serverPath:serverPath isLast:isLast index:index];
                        }
                    }];


    downloadTask.priority = 0.0f;//NSURLSessionTaskPriorityLow;
    [downloadTask resume];

    return progress;
}

- (void)onSucceessImage:(NSString *)localFilePath serverPath:(NSString *)serverPath isLast:(BOOL)isLast index:(NSInteger)index
{
    NSString *saveImagePath = [self makePath:serverPath index:index];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:saveImagePath];
    if (fileExists) {
        [fileManager removeItemAtPath:saveImagePath error:nil];
    }

    BOOL success = [fileManager moveItemAtPath:localFilePath toPath:saveImagePath error:nil];
    if (!success) {
        [self onFailureImage:nil];
        return;
    }

    if (isLast) {
        AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        [appDelegate show];
    }
}

- (void)onFailureImage:(NSError *)error
{
    NSLog(@"fail image");
}

- (void)doFinish
{
    [super doFinish];
}

@end
