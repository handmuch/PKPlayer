//
//  AuidoTableViewCell.m
//  PKPlayer
//
//  Created by 郭建华 on 2021/2/9.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import "AuidoTableViewCell.h"

#import "TVBAudioPlayService.h"

@interface AuidoTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign, readwrite) TVBAudioServicePlayStatus playStatus;
@property (nonatomic, assign, readwrite) NSTimeInterval playingTime;
@property (nonatomic, assign) CGFloat playingProgress;
@property (nonatomic, copy) NSString *playingUrl;

@property (nonatomic, strong) UIButton *opMusicButton;
@property (nonatomic, strong) UIButton *edMusicButton;

@property (nonatomic, strong) NSTimer *playTimer;


@end

@implementation AuidoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self resetConfig];
        [self setupObserve];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.contentView).offset(10);
        make.height.mas_equalTo(17);
    }];
    
    [self.contentView addSubview:self.opMusicButton];
    [self.opMusicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    self.opMusicButton.layer.cornerRadius = 10;
    self.opMusicButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.opMusicButton.layer.borderWidth = 1;
    
    [self.contentView addSubview:self.edMusicButton];
    [self.edMusicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.opMusicButton.mas_right).offset(10);
        make.centerY.equalTo(self.opMusicButton).offset(0);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    self.edMusicButton.layer.cornerRadius = 10;
    self.edMusicButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.edMusicButton.layer.borderWidth = 1;
    
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-14);
        make.centerY.equalTo(self.opMusicButton).offset(0);
        make.height.mas_equalTo(17);
    }];
    
    [self.contentView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.opMusicButton.mas_bottom).offset(10);
        make.left.right.bottom.equalTo(self.contentView).offset(0);
        make.height.mas_equalTo(3);
    }];
}

- (void)resetConfig {
    self.playingProgress = 0.0f;
    self.progressView.progress = 0.0f;
    [self removeTimer];
}

- (void)opMusicPlay:(id)sender {
    if (self.fileModel.fileReadType != PKLocalFileReadTypeVideo) {
        return;
    }
    if (self.videoOpMusicPlay) {
        self.videoOpMusicPlay(self.fileModel);
    }
}

- (void)edMusicPlay:(id)sender {
    if (self.fileModel.fileReadType != PKLocalFileReadTypeVideo) {
        return;
    }
    if (self.videoEdMusicPlay) {
        self.videoEdMusicPlay(self.fileModel);
    }
}

- (void)setupTimer {
    __weak __typeof(self) weakSelf = self;
    self.playTimer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf.progressView setProgress:strongSelf.playingProgress animated:YES];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.playTimer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (self.playTimer) {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
}

- (void)dealloc {
    [[TVBAudioPlayService sharedInstance] pause];
    [self removeTimer];
    [self removeObserve];
}

#pragma mark - observe

- (void)setupObserve {
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [[TVBAudioPlayService sharedInstance] addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    //监控缓冲加载情况属性
    [[TVBAudioPlayService sharedInstance] addObserver:self forKeyPath:@"seekTime" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
}

- (void)removeObserve {
    [[TVBAudioPlayService sharedInstance] removeObserver:self forKeyPath:@"status"];
    [[TVBAudioPlayService sharedInstance] removeObserver:self forKeyPath:@"seekTime"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    if (![[TVBAudioPlayService sharedInstance].playingUrl.absoluteString isEqualToString:self.playingUrl]) {
        return;
    }
    if ([keyPath isEqualToString:@"status"]) {
        NSNumber *newStatus = change[NSKeyValueChangeNewKey];
        self.playStatus = [newStatus unsignedIntegerValue];
        switch (self.playStatus) {
            case TVBAudioServicePlayStatusUnknow:
                break;
            case TVBAudioServicePlayStatusReadyToPlay:
            {
                [self setupTimer];
                self.progressView.hidden = NO;
            }
                break;
            case TVBAudioServicePlayStatusPlaying:
                break;
            case TVBAudioServicePlayStatusPause:
                break;
            case TVBAudioServicePlayStatusLoadFailed:
            {
                [self resetConfig];
            }
                break;
            case TVBAudioServicePlayStatusSwitch:
                break;
            case TVBAudioServicePlayStatusStopForStatics:
                break;
            case TVBAudioServicePlayStatusFinished:
            {
//                [self resetConfig];
            }
                break;
            default:
                break;
        }
    }
    if ([keyPath isEqualToString:@"seekTime"]) {
        NSNumber *seekTimeNum = change[NSKeyValueChangeNewKey];
        NSTimeInterval seekTime = [seekTimeNum doubleValue];
        //滑杆进度
        if ([TVBAudioPlayService sharedInstance].duration == 0) {
            return;
        }
        self.playingProgress = seekTime / [TVBAudioPlayService sharedInstance].duration;
        self.playingTime = seekTime;
    }
}

#pragma mark - public

- (void)setFileModel:(PKFileModel *)fileModel {
    _fileModel = fileModel;
    self.nameLabel.text = fileModel.fileName;
}

- (void)playAudioWithUrl:(NSURL *)url {
    self.playingUrl = url.absoluteString;
    [[TVBAudioPlayService sharedInstance] playAudioWithUrl:url];
}

#pragma mark - lazyInit

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor darkTextColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _timeLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor blueColor];
        _progressView.tintColor = [UIColor whiteColor];
        _progressView.hidden = YES;
    }
    return _progressView;
}

- (UIButton *)opMusicButton {
    if (!_opMusicButton) {
        _opMusicButton = [[UIButton alloc] init];
        [_opMusicButton setTitle:@"片头曲" forState:UIControlStateNormal];
        [_opMusicButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _opMusicButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _opMusicButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_opMusicButton addTarget:self action:@selector(opMusicPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _opMusicButton;
}

- (UIButton *)edMusicButton {
    if (!_edMusicButton) {
        _edMusicButton = [[UIButton alloc] init];
        [_edMusicButton setTitle:@"片尾曲" forState:UIControlStateNormal];
        [_edMusicButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _edMusicButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _edMusicButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_edMusicButton addTarget:self action:@selector(edMusicPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _edMusicButton;
}

@end
