//
//  AppDelegate.m
//  ScaryBugsApp
//
//  Created by Ray Wenderlich on 8/11/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "AppDelegate.h"
#include "MasterViewController.h"

@interface  AppDelegate()
@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // 1. Create the master View Controller
    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    
    // 2. Add the view controller to the Window's content view
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView*)self.window.contentView).bounds;
}

- (void)show
{
    ExportPacks *exportPacks = [ExportPacks new];
    [exportPacks setStickerPackList:(NSArray <Post> *)_packDownloads];
    _exportPacks = exportPacks;

    ExportStickers *exportStickers = [ExportStickers new];
    [exportStickers setStickerList:(NSArray <PostSticker> *)_itemDownloads];
    _exportStickers = exportStickers;
    
    [_masterViewController show];
}
@end
