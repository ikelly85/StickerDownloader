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

@implementation ThumbnailWorker

SYNTHESIZE_SINGLETON_CLASS(ThumbnailWorker, sharedInstance);

- (NSString *)makePath:(NSString *)thumbnail
{
    NSArray *targetUrlList = [thumbnail componentsSeparatedByString:@"/"];
    NSString *fileName = [targetUrlList lastObject];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *fileNamePath = [NSString stringWithFormat:@"stickers/%@", fileName];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileNamePath];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    NSLog(@"%@ %d", filePath, fileExists);
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

    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [self setThumbnailUrlMapOn:appDelegate.packDownloads];
    [self setThumbnailUrlMapOn:appDelegate.itemDownloads];
    
    if ([CommonUtil isEmptyMap:thumbnailUrlMap]) {
        return NO;
    }

    NSInteger i = 0;
    NSInteger totalCount = [thumbnailUrlMap count];
    @synchronized (thumbnailUrlMap) {
        for (NSString *thumbnailPath in[thumbnailUrlMap keyEnumerator]) {
            NSString *saveImagePath = [self makePath:thumbnailPath];
            [self downloadURL:thumbnailPath toPath:saveImagePath isLast:(i == totalCount - 1)];
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
    
    for (NSString *thumbnail in thumbnailList) {
        @synchronized (thumbnailUrlMap) {
            [thumbnailUrlMap setObject:@(1) forKey:thumbnail];
        }
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

- (NSProgress *)downloadURL:(NSString *)serverPath toPath:(NSString *)path isLast:(BOOL)isLast
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
                            [self onSucceessImage:[location path] serverPath:serverPath isLast:isLast];
                        }
                    }];


    downloadTask.priority = 0.0f;//NSURLSessionTaskPriorityLow;
    [downloadTask resume];

    return progress;
}

- (void)onSucceessImage:(NSString *)localFilePath serverPath:(NSString *)serverPath isLast:(BOOL)isLast
{
    NSString *saveImagePath = [self makePath:serverPath];
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
