//
//  PKFileModel.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/4/2.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKImageCoder.h"

typedef NS_ENUM(NSInteger, PKLocalFileReadType) {
    PKLocalFileReadTypeUnknow = 0,
    PKLocalFileReadTypePhoto,
    PKLocalFileReadTypeDocument,
    PKLocalFileReadTypeAudio,
    PKLocalFileReadTypeVideo,
};

@interface PKFileModel : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger fileReadType;
@property (nonatomic, assign) NSString *extName;
@property (nonatomic, assign) double fileSize;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) double addDateTime;
@property (nonatomic, assign) double recentlyReadTime;

#pragma mark - image property

@property (nonatomic, strong)
@property (nonatomic, assign) PKLocalFileImageType imageType;

@end
