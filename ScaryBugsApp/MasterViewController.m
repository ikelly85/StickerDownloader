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

@implementation MasterViewController
{
    NSMutableArray *packDownloads;
    NSMutableArray *itemDownloads;
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
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

- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        
        [_packTextView setString:[appDelegate.exportPacks toJSONString]];
        [_itemTextView setString:[appDelegate.exportStickers toJSONString]];
        [self writeStringToFile:[appDelegate.exportPacks toJSONString] fileName:@"pack"];
        [self writeStringToFile:[appDelegate.exportStickers toJSONString] fileName:@"sticker"];
    });
}

- (void)writeStringToFile:(NSString *)jsonString fileName:(NSString *)fileName
{
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *fileNamePath = [NSString stringWithFormat:@"postSticker/%@.json", fileName];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileNamePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    // The main act...
    [[jsonString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

@end
