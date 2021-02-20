//
//  TVBVideoMusicExportSession.h
//  TVBCLive
//
//  Created by 郭建华 on 2021/1/5.
//  Copyright © 2021 TVBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TVBVideoMusicExportSession : NSObject

///初始化
- (instancetype)initWithAsset:(AVAsset *)asset;

- (instancetype)initWithUrl:(NSURL *)url;

///处理函数
- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(NSURL *outputUrl))handler
                                            error:(void (^)(NSError *error))error;
///暂停输出
- (void)cancelExport;

///视频输出路径
@property (nonatomic, copy) NSURL *outputPath;
///剪切视频时间段
@property (nonatomic, assign) CMTimeRange timeRang;


@end

NS_ASSUME_NONNULL_END
