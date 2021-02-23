//
//  TVBAudioPlayService.m
//  TVBCLive
//
//  Created by 郭建华 on 2018/5/30.
//  Copyright © 2018年 TVBC. All rights reserved.
//

#import "TVBAudioPlayService.h"
//#import "TVBSystemInfo.h"

#import <AVFoundation/AVFoundation.h>

@interface TVBAudioPlayService()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentPlyerItem;
@property (nonatomic, strong) id timeObserve;

@property (nonatomic, assign, readwrite) TVBAudioServicePlayStatus status;
@property (nonatomic, strong, readwrite) NSURL *playingUrl;
@property (nonatomic, assign, readwrite) NSTimeInterval seekTime;
@property (nonatomic, assign, readwrite) NSTimeInterval duration;

@end

@implementation TVBAudioPlayService

+ (instancetype)sharedInstance {
    static id aInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aInstance = [[self alloc] init];
    });
    return aInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.autoPlay = YES;
        self.duration = 0.0f;
        [self setupPlayerObserve];
    }
    return self;
}

#pragma mark - private

- (void)setupPlayerObserve {
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //缓存够了，可以播放
    [self.player.currentItem addObserver:self forKeyPath:@"playbackLikeToKeepUp" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //监控缓冲加载情况属性
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //监控音频时长
    [self.player.currentItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //是否暂停
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //监控播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    @weakify(self);
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self);
        self.seekTime = CMTimeGetSeconds(time);
        if (self.seekTime > 0 && self.player.rate > 0.0f) {
            self.status = TVBAudioServicePlayStatusPlaying;
        }
    }];
}

- (void)removePlayObserve {
    if(self.currentPlyerItem && self.player){
        @try {
            [self.player.currentItem removeObserver:self forKeyPath:@"status"];
            [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
            [self.player.currentItem removeObserver:self forKeyPath:@"duration"];
            [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikeToKeepUp"];
        } @catch (NSException *exception) {
            NSLog(@"TVB:asset failed to remove time obsever");
        }
        if (self.timeObserve) {
            @try {
                [self.player removeTimeObserver:self.timeObserve];
            } @catch (NSException *exception) {
                NSLog(@"TVB:failed to remove time obsever");
            }
            self.timeObserve = nil;
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                self.status = TVBAudioServicePlayStatusUnknow;
                break;
            case AVPlayerStatusReadyToPlay:
                self.status = TVBAudioServicePlayStatusReadyToPlay;
                NSLog(@"KVO：准备完毕，可以播放");
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                self.status = TVBAudioServicePlayStatusLoadFailed;
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        AVPlayerItem *songItem = object;
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSArray *array = songItem.loadedTimeRanges;
            CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
            NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
            NSLog(@"共缓冲%.2f",totalBuffer);
        }
    }else if ([keyPath isEqualToString:@"duration"]) {
        self.duration = CMTimeGetSeconds(self.player.currentItem.duration);
    }else if ([keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 1.0f) {
            self.status = TVBAudioServicePlayStatusPlaying;
        }else if (self.status != TVBAudioServicePlayStatusFinished) {
            self.status = TVBAudioServicePlayStatusPause;
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL canplay = self.player.currentItem.playbackLikelyToKeepUp;
        if (canplay) {
            NSLog(@"==============>音乐可以播放了");
        }else{
            NSLog(@"==============>音乐暂时不能播放");
        }
    }
}

- (void)playbackFinished:(NSNotification *)notice {
    NSLog(@"播放完成");
    self.status = TVBAudioServicePlayStatusFinished;
}

#pragma mark - public

- (void)playAudioWithUrl:(NSURL *)audioUrl {

    if (![[self.playingUrl absoluteString] isEqualToString:[audioUrl absoluteString]]) {
        self.status = TVBAudioServicePlayStatusSwitch;
    }
    self.playingUrl = audioUrl;
    [self shutDown];
    
    AVPlayerItem *audioItem = [[AVPlayerItem alloc]initWithURL:audioUrl];
    self.currentPlyerItem = audioItem;
    [self.player replaceCurrentItemWithPlayerItem:audioItem];
    
    if (self.autoPlay) {
        [self play];
    }
}

- (void)play {
    
//    if ([[TVBSystemInfo networkType] isEqualToString:@"NoNetWork"]) {
//        [TVBNoticeViewService showMessage:@"网络有点low，快给手机做做体检"];
//        return;
//    }
    
    [self setupPlayerObserve];
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)resume {
//    if ([[TVBSystemInfo networkType] isEqualToString:@"NoNetWork"]) {
//        [TVBNoticeViewService showMessage:@"网络有点low，快给手机做做体检"];
//        return;
//    }
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)shutDown {
    [self removePlayObserve];
    [self.player pause];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
}

- (void)seekToTime:(NSTimeInterval)time {
    
//    if ([[TVBSystemInfo networkType] isEqualToString:@"NoNetWork"]) {
//        [TVBNoticeViewService showMessage:@"网络有点low，快给手机做做体检"];
//        return;
//    }
    
    if (self.status > TVBAudioServicePlayStatusUnknow && CMTIME_IS_VALID(CMTimeMake(time, self.player.currentItem.duration.timescale))) {
        [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentItem.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.player play];
                });
            }
        }];
    }
}

- (void)stopForStatics {
    self.status = TVBAudioServicePlayStatusStopForStatics;
    [self.player pause];
}

#pragma mark - lazyInit

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc]init];
        _player.volume = 1.0f;
    }
    
    return _player;
}

@end
