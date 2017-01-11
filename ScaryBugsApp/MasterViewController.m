//
//  MasterViewController.m
//  ScaryBugsApp
//
//  Created by Ray Wenderlich on 8/11/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "MasterViewController.h"
#import "Post.h"
#import "PostSticker.h"
#import "AppDelegate.h"
#import "ThumbnailWorker.h"
#import "StringUtils.h"
#import "ContentsModel.h"

@implementation MasterViewController
{
    NSMutableArray *packDownloads;
    NSMutableArray *itemDownloads;
    NSFileManager *fileManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    fileManager = [NSFileManager defaultManager];
    
    [self makeDir];
    
    packDownloads = [NSMutableArray array];
    itemDownloads = [NSMutableArray array];
    
    [Post globalTimelinePostsWithBlock:^(NSArray *posts, NSError *error) {
        if (error) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = NSLocalizedString(@"Error", nil);
            alert.informativeText = error.localizedDescription;
            [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alert runModal];
        }
        
        __block NSInteger i = 0;
        for (Post *post in posts) {
            [packDownloads addObject:post];
            
            [PostSticker globalTimelinePostsWithBlock:post.stickerPackSeq stickerPackId:post.stickerPackId block:^(NSArray *postStickers, NSError *error) {
                if (postStickers && [postStickers count] > 0) {
                    for (PostSticker *postSticker in postStickers) {
                        [itemDownloads addObject:postSticker];
                    }
                }
                
                if (i == [posts count] - 1) {
                    [self download];
                }
                
                i++;
            }];
        }
        
    }];
}

- (void)makeDir
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *postStickerPath = [documentsPath stringByAppendingPathComponent:@"postSticker"];
    if (![fileManager fileExistsAtPath:postStickerPath]) {
        [fileManager createDirectoryAtPath:postStickerPath withIntermediateDirectories:NO attributes:nil error:nil];
    }

    NSString *imagesPath = [postStickerPath stringByAppendingPathComponent:@"images"];
    if (![fileManager fileExistsAtPath:imagesPath]) {
        [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

- (void)download
{
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate setPackDownloads:packDownloads];
    [appDelegate setItemDownloads:itemDownloads];
    [[ThumbnailWorker sharedInstance] notify];
    
}

- (void)cleansing
{
    NSString *applicationPath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    NSString *assetPath = [applicationPath stringByAppendingPathComponent:@"Images.xcassets/post_stickers"];
    
    [fileManager removeItemAtPath:assetPath error:nil];
    [fileManager createDirectoryAtPath:assetPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    ContentsModel *contentsModel = [ContentsModel new];
    InfoModel *infoModel = [InfoModel new];
    [infoModel setAuthor:@"xcode"];
    [infoModel setVersion:1];
    [contentsModel setInfo:infoModel];
    
    NSString *jsonText = [contentsModel toJSONString];
    NSString *contentsFilePath = [assetPath stringByAppendingPathComponent:@"Contents.json"];
    if (![fileManager fileExistsAtPath:contentsFilePath]) {
        [fileManager createFileAtPath:contentsFilePath contents:nil attributes:nil];
    }
    
    [[jsonText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:contentsFilePath atomically:NO];
}

- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        
        [_packTextView setString:[appDelegate.exportPacks toJSONString]];
        [_itemTextView setString:[appDelegate.exportStickers toJSONString]];
        
        [self writeStringToFile:[appDelegate.exportPacks toJSONString] fileName:@"pack"];
        [self writeStringToFile:[appDelegate.exportStickers toJSONString] fileName:@"sticker"];
        
        [self cleansing];
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *docResourcePath = [docPath stringByAppendingPathComponent:@"postSticker"];

        NSString *applicationPath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
        NSString *assetPath = [applicationPath stringByAppendingPathComponent:@"Images.xcassets/post_stickers"];
        
        
        NSURL *directoryURL = [NSURL fileURLWithPath:docResourcePath isDirectory:YES];
        NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
        
        NSDirectoryEnumerator *enumerator = [fileManager
                                             enumeratorAtURL:directoryURL
                                             includingPropertiesForKeys:keys
                                             options:0
                                             errorHandler:^(NSURL *url, NSError *error) {
                                                 // Handle the error.
                                                 // Return YES if the enumeration should continue after the error.
                                                 return YES;
                                             }];
        
        for (NSURL *url in enumerator) { 
            NSError *error;
            NSNumber *isDirectory = nil;
            if (![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
                // handle error
            } else {
                // No error and it’s not a directory; do something with the file
                if (![isDirectory boolValue]) {
                    if ([url.lastPathComponent hasSuffix:@".json"]) {
                        NSString *jsonResourcePath = [applicationPath stringByAppendingPathComponent:@"Resources/postSticker"];
                        NSURL *destURL = [NSURL fileURLWithPath:[jsonResourcePath stringByAppendingPathComponent:url.lastPathComponent] isDirectory:NO];
                        [fileManager copyItemAtURL:url toURL:destURL error:&error];
                    } else {
                        NSString *assetImage = [[url.lastPathComponent stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
                        NSString *assetImageFolderName = [assetImage stringByAppendingString:@".imageset"];
                        NSString *assetImageFolder = [assetPath stringByAppendingPathComponent:assetImageFolderName];
                        [fileManager createDirectoryAtPath:assetImageFolder withIntermediateDirectories:NO attributes:nil error:nil];
                        
                        NSURL *destURL = [NSURL fileURLWithPath:[assetImageFolder stringByAppendingPathComponent:url.lastPathComponent] isDirectory:NO];
                        [fileManager copyItemAtURL:url toURL:destURL error:&error];
                        
                        ContentsModel *contentsModel = [ContentsModel new];
                        ImageModel *imageModel = [ImageModel new];
                        [imageModel setIdiom:@"universal"];
                        [imageModel setFilename:url.lastPathComponent];
                        [imageModel setScale:@"3x"];
                        [contentsModel setImages:(NSArray <ImageModel> *)@[imageModel]];
                        
                        InfoModel *infoModel = [InfoModel new];
                        [infoModel setAuthor:@"xcode"];
                        [infoModel setVersion:1];
                        [contentsModel setInfo:infoModel];
                        
                        NSString *jsonText = [contentsModel toJSONString];
                        NSString *contentsFilePath = [assetImageFolder stringByAppendingPathComponent:@"Contents.json"];
                        if (![fileManager fileExistsAtPath:contentsFilePath]) {
                            [fileManager createFileAtPath:contentsFilePath contents:nil attributes:nil];
                        }

                        [[jsonText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:contentsFilePath atomically:NO];
                    }
                }
            }
        }
        
        [fileManager removeItemAtPath:docResourcePath error:nil];
        [NSApp terminate:self];
    });
}

- (void)writeStringToFile:(NSString *)jsonString fileName:(NSString *)fileName
{
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *fileNamePath = [NSString stringWithFormat:@"postSticker/%@.json", fileName];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileNamePath];
    
    if (![fileManager fileExistsAtPath:fileAtPath]) {
        [fileManager createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    // The main act...
    [[jsonString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

@end
