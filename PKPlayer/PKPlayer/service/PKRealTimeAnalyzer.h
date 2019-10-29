//
//  PKRealTimeAnalyzer.h
//  PKPlayer
//
//  Created by 郭建华 on 2019/3/7.
//  Copyright © 2019 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>

//system
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKRealTimeAnalyzer : NSObject

@property (nonatomic, assign) NSInteger fftSize;
@property (nonatomic, assign) NSInteger frequencyBands; //频带数量
@property (nonatomic, assign) CGFloat startFrequency;   //起始频率
@property (nonatomic, assign) CGFloat endFrequency;     //截止频率

@property (nonatomic, assign) CGFloat spectrumSmooth;

/**
 信号处理，返回
 
 @param buffer 信号数据
 @return 具体频率信号强度
 */
- (NSMutableArray *)fftBuffer:(AVAudioPCMBuffer *)buffer;


- (NSMutableArray <NSArray *>*)analyseWithBuffer:(AVAudioPCMBuffer *)buffer;

@end

NS_ASSUME_NONNULL_END


@interface PKWaveBand : NSObject

- (instancetype)initWithlowerFrequency:(CGFloat)lowerFrequency
                        upperFrequency:(CGFloat)upperFrequency;

@property (nonatomic, assign) CGFloat lowerFrequency;
@property (nonatomic, assign) CGFloat upperFrequency;

@end
