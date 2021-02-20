//
//  PKFilePhotoSourceService.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/5/8.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKFilePhotoSourceService.h"

#import <YYImage/YYImage.h>

@implementation PKFilePhotoSourceService {
    dispatch_semaphore_t _preloadedLock;
}

+ (instancetype)sharedInstance {
    static id aInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aInstance = [[self alloc] init];
    });
    return aInstance;
}


- (PKFileImageModel *)photoFileModelWithImagePath:(NSString *)imagePath {
    
    PKFileImageModel *imageModel = [[PKFileImageModel alloc]init];
    
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    @autoreleasepool {
        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:data scale:1];
        YYImageFrame *imageFrame = [decoder frameAtIndex:0 decodeForDisplay:YES];
        imageModel.imageType = decoder.type;
        if (imageFrame) {
            imageModel.imageWidth = imageFrame.width;
            imageModel.imageHeight = imageFrame.height;
            imageModel.animateDuration = imageFrame.duration;
        }
        return imageModel;
    }
    return nil;
}

@end
