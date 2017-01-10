//
//  ExportPacks.h
//  ScaryBugsApp
//
//  Created by kelly on 2017. 1. 10..
//  Copyright © 2017년 Ray Wenderlich. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "Post.h"

@interface ExportPacks : JSONModel
@property (strong, nonatomic) NSArray <Post> *stickerPackList;
@end
