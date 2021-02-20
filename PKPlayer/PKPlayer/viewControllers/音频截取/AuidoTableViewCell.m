//
//  AuidoTableViewCell.m
//  PKPlayer
//
//  Created by 郭建华 on 2021/2/9.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import "AuidoTableViewCell.h"

@interface AuidoTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIButton *opMusicButton;
@property (nonatomic, strong) UIButton *edMusicButton;

@end

@implementation AuidoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.contentView).offset(7);
        make.height.mas_equalTo(17);
    }];
    
    [self.contentView addSubview:self.opMusicButton];
    [self.opMusicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(7);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    
    [self.contentView addSubview:self.edMusicButton];
    [self.edMusicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.opMusicButton.mas_right).offset(7);
        make.centerY.equalTo(self.opMusicButton).offset(0);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    
    [self.contentView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.opMusicButton.mas_bottom).offset(7);
        make.left.right.bottom.equalTo(self.contentView).offset(0);
        make.height.mas_equalTo(3);
    }];
}

#pragma mark - public

- (void)setFileModel:(PKFileModel *)fileModel {
    _fileModel = fileModel;
    self.nameLabel.text = fileModel.fileName;
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

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor blueColor];
        _progressView.tintColor = [UIColor whiteColor];
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
    }
    return _edMusicButton;
}

@end
