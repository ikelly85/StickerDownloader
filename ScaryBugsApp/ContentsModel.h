//
//  ContentsModel.h
//  ScaryBugsApp
//
//  Created by kelly on 2017. 1. 11..
//  Copyright © 2017년 Ray Wenderlich. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol ImageModel <NSObject>
@end

@interface ImageModel : JSONModel
@property (nonatomic, strong) NSString *idiom;
@property (nonatomic, strong) NSString *scale;
@property (nonatomic, strong) NSString *filename;
@end

@protocol InfoModel<NSObject>
@end

@interface InfoModel : JSONModel
@property (nonatomic, strong) NSString *author;
@property (nonatomic) NSInteger version;
@end

@interface ContentsModel : JSONModel
@property (nonatomic, strong) NSArray <ImageModel> *images;
@property (nonatomic, strong) InfoModel *info;
@end
