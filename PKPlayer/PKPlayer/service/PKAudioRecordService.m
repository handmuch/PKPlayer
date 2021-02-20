//
//  PKAudioRecordService.m
//  PKPlayer
//
//  Created by 郭建华 on 2020/8/4.
//  Copyright © 2020 PeterKwok. All rights reserved.
//

#import "PKAudioRecordService.h"
#import <AVFoundation/AVFoundation.h>

#define kOutputBus 0
#define kInputBus 1

@interface PKAudioRecordService (){
    AudioStreamBasicDescription audioFormat;
}

@property (nonatomic, assign) AudioUnit rioUnit;
@property (nonatomic, assign) AudioBufferList bufferList;

@end

@implementation PKAudioRecordService

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
        
    }
    return self;
}

- (void)setupConfig {
    OSStatus status;
    AudioComponentInstance audioUnit;
    
    // Describe audio component
    // 描述音频元件
    AudioComponentDescription desc;
    desc.componentType                      = kAudioUnitType_Output;
    desc.componentSubType                   = kAudioUnitSubType_RemoteIO;
    desc.componentFlags                     = 0;
    desc.componentFlagsMask                 = 0;
    desc.componentManufacturer              = kAudioUnitManufacturer_Apple;
    // Get component
    // 获得一个元件
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    // Get audio units
    // 获得 Audio Unit
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    checkStatus(status);
    
    // Enable IO for recording
    // 为录制打开 IO
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    // Enable IO for playback
    // 为播放打开 IO
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    // Describe format
    // 描述格式
    audioFormat.mSampleRate                 = 48000.00;
    audioFormat.mFormatID                   = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags                = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket            = 1;
    audioFormat.mChannelsPerFrame           = 1;
    audioFormat.mBitsPerChannel             = 16;
    audioFormat.mBytesPerPacket             = 2;
    audioFormat.mBytesPerFrame              = 2;
}

// 检测状态
void checkStatus(OSStatus status) {
    if(status!=0)
        printf("Error: %d\n", (int)status);
}

@end
