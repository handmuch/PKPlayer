//
//  TVBAudioPlayService.h
//  TVBCLive
//
//  Created by 郭建华 on 2018/5/30.
//  Copyright © 2018年 TVBC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TVBAudioServicePlayStatus) {
    TVBAudioServicePlayStatusUnknow = 0,
    TVBAudioServicePlayStatusReadyToPlay,
    TVBAudioServicePlayStatusLoadFailed,
    TVBAudioServicePlayStatusPlaying,
    TVBAudioServicePlayStatusPause,
    TVBAudioServicePlayStatusSwitch,
    TVBAudioServicePlayStatusStopForStatics,
    TVBAudioServicePlayStatusFinished,
};

@interface TVBAudioPlayService : NSObject

@property (nonatomic, assign) BOOL autoPlay;

@property (nonatomic, assign, readonly) TVBAudioServicePlayStatus status;
@property (nonatomic, strong, readonly) NSURL *playingUrl;
@property (nonatomic, assign, readonly) NSTimeInterval seekTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;

@property (nonatomic, copy) NSString *modelLocation;

+ (instancetype)sharedInstance;

- (void)playAudioWithUrl:(NSURL *)audioUrl;
- (void)play;
- (void)resume;
- (void)pause;

- (void)seekToTime:(NSTimeInterval)time;

///为统计而生
- (void)stopForStatics;

@end
