//
//  ExportStickers.h
//  ScaryBugsApp
//
//  Created by kelly on 2017. 1. 10..
//  Copyright © 2017년 Ray Wenderlich. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "PostSticker.h"

@interface ExportStickers : JSONModel

@property (strong, nonatomic) NSArray <PostSticker> *stickerList;
@end
