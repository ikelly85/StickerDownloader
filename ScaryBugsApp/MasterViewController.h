//
//  MasterViewController.h
//  ScaryBugsApp
//
//  Created by Ray Wenderlich on 8/11/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MasterViewController : NSViewController
@property (unsafe_unretained) IBOutlet NSTextView *packTextView;
@property (unsafe_unretained) IBOutlet NSTextView *itemTextView;

- (void)show;
@end
