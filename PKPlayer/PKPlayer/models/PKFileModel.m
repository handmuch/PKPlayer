//
//  PKFileModel.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/4/2.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKFileModel.h"

@implementation PKFileImageModel

@end

@implementation PKFileModel

+ (UIImage *)contentImageWithFileModel:(PKFileModel *)file {
    UIImage *image = nil;
    switch ((NSInteger)file.fileReadType) {
        case PKLocalFileReadTypeUnknow:
            image = [UIImage imageNamed:@"local_file_unknow.png"];
            break;
        case PKLocalFileReadTypePhoto:
            image = [UIImage imageWithContentsOfFile:file.filePath];
            break;
        case PKLocalFileReadTypeDocument:
            image = [UIImage imageNamed:@"local_file_txt"];
            break;
        default:
            break;
    }
    return image;
}

@end
