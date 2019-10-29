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
    
    
    ///原始方法
    /*
    CGImageSourceRef  cImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
    if (cImageSource == NULL) {
        return nil;
    }
    CGFloat width = 0.0f, height = 0.0f;
    CGFloat size = 0.0f;
    NSString *imageName = nil;
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0, NULL);
    CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
    if (widthNum != NULL) {
        CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
    }
    
    CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
    if (heightNum != NULL) {
        CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
    }
    
    CFNumberRef sizeNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyFileSize);
    if (sizeNum != NULL) {
        CFNumberGetValue(sizeNum, kCFNumberFloatType, &size);
    }
    
    CFStringRef fileName = CFDictionaryGetValue(imageProperties, kCGImagePropertyProfileName);
    if (fileName != NULL) {
        imageName = (__bridge NSString *)fileName;
    }
    
    PKFileModel *fileModel = [[PKFileModel alloc]init];
    fileModel.fileName = imageName;
    fileModel.fileSize = size;
    
    CFRelease(imageProperties);
     */
    
    
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
