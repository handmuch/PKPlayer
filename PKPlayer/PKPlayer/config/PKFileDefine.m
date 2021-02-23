//
//  PKFileDefine.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/5/14.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKFileDefine.h"

static NSString *const jpgSuffix = @"jpg";
static NSString *const jpegSuffix = @"jepg";
static NSString *const pngSuffix = @"png";
static NSString *const bmpSuffix = @"bmp";
static NSString *const gifSuffix = @"gif";
static NSString *const pcxSuffix = @"pcx";
static NSString *const tiffSuffix = @"tiff";
static NSString *const tgaSuffix = @"tga";
static NSString *const exifSuffix = @"exif";
static NSString *const icoSuffix = @"ico";
static NSString *const icnsSuffix = @"icns";

static NSString *const mp4Suffix = @"mp4";

@implementation PKFileDefine

+ (BOOL)isImageFile:(NSString *)fileName {
    if (fileName.length <= 0) {
        return NO;
    }
    
    if ([fileName hasSuffix:jpegSuffix] ||
        [fileName hasSuffix:jpgSuffix] ||
        [fileName hasSuffix:pngSuffix] ||
        [fileName hasSuffix:bmpSuffix] ||
        [fileName hasSuffix:gifSuffix] ||
        [fileName hasSuffix:pcxSuffix] ||
        [fileName hasSuffix:tiffSuffix] ||
        [fileName hasSuffix:tgaSuffix] ||
        [fileName hasSuffix:exifSuffix] ||
        [fileName hasSuffix:icoSuffix] ||
        [fileName hasSuffix:icnsSuffix]) {
        
        return YES;
    }
    
    return NO;
}

+ (BOOL)isVideoFile:(NSString *)fileName {
    if (fileName.length <= 0) {
        return NO;
    }
    
    if ([fileName hasSuffix:mp4Suffix]) {
        return YES;
    }
    
    return NO;
}

///片头曲地址
+ (NSString *)exportOpMusicfileName:(NSString *)fileName {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"op.m4a"]];
}

///片尾曲地址
+ (NSString *)exportEdMusicfileName:(NSString *)fileName {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"ed.m4a"]];
}

@end
