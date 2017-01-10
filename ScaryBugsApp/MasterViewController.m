//
//  MasterViewController.m
//  ScaryBugsApp
//
//  Created by Ray Wenderlich on 8/11/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "MasterViewController.h"
#import "ScaryBugDoc.h"
#import "ScaryBugData.h"
#import "Post.h"
#import "PostSticker.h"
#import "AppDelegate.h"
#import "ThumbnailWorker.h"

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
            [packDownloads addObject:post.thumbnailOn];
            [packDownloads addObject:post.thumbnailOff];
            
            [PostSticker globalTimelinePostsWithBlock:post.stickerPackSeq block:^(NSArray *postStickers, NSError *error) {
                if (postStickers && [postStickers count] > 0) {
                    for (PostSticker *postSticker in postStickers) {
                        [itemDownloads addObject:postSticker.thumbnail];
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

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    // Since this is a single-column table view, this would not be necessary.
    // But it's a good practice to do it in order by remember it when a table is multicolumn.
    if( [tableColumn.identifier isEqualToString:@"BugColumn"] )
    {
        ScaryBugDoc *bugDoc = [self.bugs objectAtIndex:row];
        cellView.imageView.image = bugDoc.thumbImage;
        cellView.textField.stringValue = bugDoc.data.title;
        return cellView;
    }
    return cellView;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.bugs count];
}

@end
