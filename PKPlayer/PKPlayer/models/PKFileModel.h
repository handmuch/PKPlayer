//
//  PKFileModel.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/4/2.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKFileModel : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger fileReadType;
@property (nonatomic, assign) NSInteger fileType;
@property (nonatomic, assign) double fileSize;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) double addDateTime;
@property (nonatomic, assign) double recentlyReadTime;

@end
