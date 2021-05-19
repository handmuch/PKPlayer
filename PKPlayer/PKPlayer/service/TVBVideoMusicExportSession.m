//
//  TVBVideoMusicExportSession.m
//  TVBCLive
//
//  Created by 郭建华 on 2021/1/5.
//  Copyright © 2021 TVBC. All rights reserved.
//

#import "TVBVideoMusicExportSession.h"

@interface TVBVideoMusicExportSession ()

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) AVMutableComposition *composition;

@end

@implementation TVBVideoMusicExportSession

- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if(self) {
        _asset = asset;
        _timeRang = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)url {
    AVAsset *asset = [AVAsset assetWithURL:url];
    return [self initWithAsset:asset];
}

- (void)dealloc {
    [self.exportSession cancelExport];
    self.exportSession = nil;
    self.composition = nil;
}

#pragma mark - public

- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(NSURL *))handler error:(void (^)(NSError *))error {
    [self.exportSession cancelExport];
    self.exportSession = nil;
    self.composition = nil;
    
    NSError *err = nil;
    if (self.outputPath.path.length == 0) {
        err = [NSError errorWithDomain:PKPlayerErrorDomain code:201 userInfo:@{NSLocalizedDescriptionKey : @"音频输出地址为空"}];
        error(err);
        return;
    }

    NSFileManager *fileManager = [[NSFileManager alloc]init];
    ///删除输出地址原理存在的视频
    BOOL exist = [fileManager fileExistsAtPath:self.outputPath.path];
    if (exist) {
        if (![fileManager removeItemAtURL:self.outputPath error:&err]) {
            NSLog(@"removeTrimPath error: %@ \n",[error localizedDescription]);
        }
    }
    
    AVAssetTrack *assetAudioTrack = nil;
    AVAssetTrack *assetVideoTrack = nil;
    if ([self.asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
        assetAudioTrack = [[self.asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    }
    if ([self.asset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        assetVideoTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    
    ///第一步
    ///创建composition插入Asset中的视频轨和音频轨
    self.composition = [[AVMutableComposition alloc]init];
    ///处理视频
    if (assetVideoTrack) {
        AVMutableCompositionTrack *compositionVideoTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
        ///视频方向
        [compositionVideoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
        ///把视频轨数据加到可变轨道中，并根据timeRange作剪裁
        [compositionVideoTrack insertTimeRange:self.timeRang ofTrack:assetVideoTrack atTime:insertionPoint error:&err];
    }
    ///处理音频
    if (assetAudioTrack) {
        AVMutableCompositionTrack *compositionAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack setPreferredTransform:assetAudioTrack.preferredTransform];
        [compositionAudioTrack insertTimeRange:self.timeRang ofTrack:assetAudioTrack atTime:insertionPoint error:&err];
    }
    
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:self.asset presetName:AVAssetExportPresetAppleM4A];
    self.exportSession.timeRange = self.timeRang;
    self.exportSession.outputURL = self.outputPath;
    self.exportSession.outputFileType = AVFileTypeAppleM4A;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export completed");
                    break;
                default:
                    break;
            }
            BOOL completed = [self.exportSession status] == AVAssetExportSessionStatusCompleted;
            BOOL fileExists = [fileManager fileExistsAtPath:self.outputPath.path];
            if (completed && fileExists) {
                if (handler) handler(self.outputPath);
            } else {
                if (error) error(self.exportSession.error);
            }
        });
    }];
}

- (void)cancelExport{
    [self.exportSession cancelExport];
}


@end
