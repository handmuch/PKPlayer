//
//  PKAudioWaveDisplayPlayer.m
//  PKPlayer
//
//  Created by 郭建华 on 2019/2/28.
//  Copyright © 2019 PeterKwok. All rights reserved.
//

#import "PKAudioWaveDisplayPlayer.h"
#import "PKUtilities.h"

//system
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

@interface PKAudioWaveDisplayPlayer (){
}

@property (nonatomic, assign) int bufferSize;
@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *player;

@property (nonatomic, strong, readwrite) PKRealTimeAnalyzer *analyzer;

@end

@implementation PKAudioWaveDisplayPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - private

- (void)setBufferSize:(int)bufferSize {
    _bufferSize = bufferSize;
    __weak typeof(self) weakSelf =self;
    [self.engine.mainMixerNode removeTapOnBus:0];
    [self.engine.mainMixerNode installTapOnBus:0 bufferSize:(AVAudioFrameCount)bufferSize format:nil block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.player.isPlaying) {
            return;
        }
        buffer.frameLength = (AVAudioFrameCount)bufferSize;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *amplitudes = [strongSelf.analyzer analyseWithBuffer:buffer];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(player:didGenerateSpectrum:)]) {
                    [strongSelf.delegate player:strongSelf didGenerateSpectrum:amplitudes];
                }
            });
        });
    }];
}

- (void)setup {
    [self.engine attachNode:self.player];
    [self.engine connect:self.player to:self.engine.mainMixerNode format:nil];
    [self.engine prepare];
    NSError *error = nil;
    [self.engine startAndReturnError:&error];
    @onExit {
        self.bufferSize = 2048;
    };
}

#pragma mark - public

- (void)playWithFilePath:(NSString *)filePath {
    NSURL *audioFileURL = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    AVAudioFile *file = [[AVAudioFile alloc]initForReading:audioFileURL error:&error];
    [self.player stop];
    if (file && !error) {
        [self.player scheduleFile:file atTime:nil completionHandler:nil];
        [self.player play];
    }else{
        NSLog(@"=============>播放文件有问题<=============");
    }
}

- (void)stop {
    [self.player stop];
}

#pragma mark - lazyInit

- (AVAudioEngine *)engine {
    if (!_engine) {
        _engine = [[AVAudioEngine alloc]init];
    }
    return _engine;
}

- (AVAudioPlayerNode *)player {
    if (!_player) {
        _player = [[AVAudioPlayerNode alloc]init];
    }
    return _player;
}

- (PKRealTimeAnalyzer *)analyzer {
    if (!_analyzer) {
        _analyzer = [[PKRealTimeAnalyzer alloc]init];
    }
    return _analyzer;
}

@end
