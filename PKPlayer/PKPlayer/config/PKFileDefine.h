//
//  PKFileDefine.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/5/14.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKFileDefine : NSObject

+ (BOOL)isImageFile:(NSString *)fileName;

+ (BOOL)isVideoFile:(NSString *)fileName;

///片头曲地址
+ (NSString *)exportOpMusicfileName:(NSString *)fileName;

///片尾曲地址
+ (NSString *)exportEdMusicfileName:(NSString *)fileName;

@end
