//
//  PKFilePhotoSourceService.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/5/8.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PKFileModel.h"

@interface PKFilePhotoSourceService : NSObject

+ (instancetype)sharedInstance;

- (PKFileImageModel *)photoFileModelWithImagePath:(NSString *)imagePath;

@end
