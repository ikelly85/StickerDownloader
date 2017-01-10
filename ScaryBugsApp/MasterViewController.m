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
            
            [PostSticker globalTimelinePostsWithBlock:post.stickerPackSeq block:^(NSArray *postStickers, NSError *error) {
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
    });
}

@end
