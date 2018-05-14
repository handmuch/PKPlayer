//
//  PKFilePhotoSourceService.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/5/8.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKFilePhotoSourceService.h"

#import "PKFileModel.h"

@implementation PKFilePhotoSourceService

+ (instancetype)sharedInstance {
    static id aInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aInstance = [[self alloc] init];
    });
    return aInstance;
}

- (PKFileModel *)photoFileModelWithImagePath:(NSString *)imagePath {
    
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
}
    
    
}

@end
