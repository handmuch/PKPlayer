//
//  PKFileModel.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/4/2.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYImage/YYImage.h>

typedef NS_ENUM(NSInteger, PKLocalFileReadType) {
    PKLocalFileReadTypeUnknow = 0,
    PKLocalFileReadTypePhoto,
    PKLocalFileReadTypeDocument,
    PKLocalFileReadTypeAudio,
    PKLocalFileReadTypeVideo,
};

@interface PKFileImageModel : NSObject

@property (nonatomic, assign) YYImageType imageType;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) NSTimeInterval animateDuration;

@end

@interface PKFileModel : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) PKLocalFileReadType fileReadType;
@property (nonatomic, assign) NSString *extName;
@property (nonatomic, assign) long long fileSize;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) double createDateTime;
@property (nonatomic, assign) double modifyDateTime;

#pragma mark - image

@property (nonatomic, strong) PKFileImageModel *imageModel;

+ (UIImage *)contentImageWithFileModel:(PKFileModel *)file;

@end
