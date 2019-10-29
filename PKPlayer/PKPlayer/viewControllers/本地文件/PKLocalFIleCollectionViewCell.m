//
//  PKLocalFIleCollectionViewCell.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/5/4.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKLocalFileCollectionViewCell.h"

@interface PKLocalFileCollectionViewCell()

@property (nonatomic, strong) UIImageView *contentImage;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation PKLocalFileCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    
    [self.contentView addSubview:self.contentImage];
    [self.contentImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset (10);
        make.centerX.equalTo(self.contentView).offset(0);
        make.size.mas_equalTo(CGSizeMake(90, 90));
    }];
    
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentImage.mas_bottom).offset(6);
        make.left.equalTo(self.contentView).offset(0);
        make.right.equalTo(self.contentView).offset(0);
        make.bottom.equalTo(self.contentView).offset(0);
    }];
}

#pragma mark - public

- (void)setFile:(PKFileModel *)file {
    _file = file;
    self.contentLabel.text = file.fileName;
    self.contentImage.image = [PKFileModel contentImageWithFileModel:file];
}

+ (CGSize)localFileCollectionViewCellSize {
    CGFloat width = (PK_SCREEN_WIDTH - 4*12)/3;
    CGFloat height = 130;
    return CGSizeMake(width, height);
}

#pragma mark - lazyInit

- (UIImageView *)contentImage {
    if (!_contentImage) {
        _contentImage = [[UIImageView alloc]init];
        _contentImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _contentImage;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont systemFontOfSize:13.0f];
        _contentLabel.textColor = [UIColor blackColor];
    }
    return _contentLabel;
}

@end
