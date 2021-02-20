//
//  PKRecordViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2020/8/4.
//  Copyright © 2020 PeterKwok. All rights reserved.
//

#import "PKRecordViewController.h"

#import "LFAudioCapture.h"
#import "LFLiveAudioConfiguration.h"

@interface PKRecordViewController ()<LFAudioCaptureDelegate>

@property (nonatomic, strong) UIButton *recordButton;

/// 音频采集
@property (nonatomic, strong) LFAudioCapture *audipCapture;
/// 音频配置
@property (nonatomic, strong) LFLiveAudioConfiguration *audioConfiguration;

@end

@implementation PKRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.recordButton];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 35));
    }];
    self.recordButton.layer.cornerRadius = 17.5;
    self.recordButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.recordButton.layer.borderWidth = 1.0f;
}

#pragma mark - action

- (void)beginRecord:(UIButton *)sender {
    self.recordButton.selected = !sender.selected;
    self.audipCapture.running = self.recordButton.selected;
}

#pragma mark - LFAudioCaptureDelegate

- (void)captureOutput:(nullable LFAudioCapture *)capture audioData:(nullable NSData*)audioData {
    
}

#pragma mark - lazyInit

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc] init];
        _recordButton.backgroundColor = [UIColor whiteColor];
        [_recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
        [_recordButton setTitle:@"停止录音" forState:UIControlStateSelected];
        [_recordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        [_recordButton addTarget:self action:@selector(beginRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

- (LFAudioCapture *)audipCapture {
    if (!_audipCapture) {
        _audipCapture = [[LFAudioCapture alloc] initWithAudioConfiguration:self.audioConfiguration];
        _audipCapture.delegate = self;
    }
    return _audipCapture;
}

- (LFLiveAudioConfiguration *)audioConfiguration {
    if (!_audioConfiguration) {
        _audioConfiguration = [LFLiveAudioConfiguration new];
        _audioConfiguration.numberOfChannels = 1;
        _audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
        _audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_48000Hz;
    }
    return _audioConfiguration;
}

@end
