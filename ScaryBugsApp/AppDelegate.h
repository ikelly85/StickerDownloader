//
//  AppDelegate.h
//  ScaryBugsApp
//
//  Created by Ray Wenderlich on 8/11/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ExportPacks.h"
#import "ExportStickers.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSArray *packDownloads;
@property (strong, nonatomic) NSArray *itemDownloads;

@property (strong, nonatomic) ExportPacks *exportPacks;
@property (strong, nonatomic) ExportStickers *exportStickers;

- (void)show;
@end
