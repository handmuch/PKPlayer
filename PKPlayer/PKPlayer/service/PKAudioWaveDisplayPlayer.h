//
//  PKAudioWaveDisplayPlayer.h
//  PKPlayer
//
//  Created by 郭建华 on 2019/2/28.
//  Copyright © 2019 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKRealTimeAnalyzer.h"

@class PKAudioWaveDisplayPlayer;

NS_ASSUME_NONNULL_BEGIN

@protocol PKAudioSpectrumPlayerDelegate <NSObject>

- (void)player:(PKAudioWaveDisplayPlayer *)player didGenerateSpectrum:(NSMutableArray *)specturm;

@end

@interface PKAudioWaveDisplayPlayer : NSObject

@property (nonatomic, strong, readonly) PKRealTimeAnalyzer *analyzer;

@property (nonatomic, assign) id<PKAudioSpectrumPlayerDelegate> delegate;

- (void)playWithFilePath:(NSString *)filePath;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
