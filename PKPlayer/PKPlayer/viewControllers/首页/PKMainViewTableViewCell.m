//
//  PKMainVIewTableViewCell.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/29.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKMainViewTableViewCell.h"

@interface PKMainViewTableViewCell()

@property (nonatomic, strong) UIImageView *cellImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrawImageView;

@end

@implementation PKMainViewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self addSubview:self.cellImageView];
    [self.cellImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(18);
        make.centerY.equalTo(self).offset(0);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cellImageView.mas_right).offset(8);
        make.right.equalTo(self.mas_right).offset(48);
        make.centerY.equalTo(self).offset(0);
        make.height.mas_equalTo(32);
    }];
}

#pragma mark - setter

- (void)setCellTitle:(NSString *)cellTitle {
    self.titleLabel.text = cellTitle;
}

- (void)setImageName:(NSString *)imageName {
    self.cellImageView.image = [UIImage imageNamed:imageName];
}

#pragma mark - lazyInit

- (UIImageView *)cellImageView {
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc]init];
    }
    return _cellImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UIImageView *)arrawImageView {
    if (!_arrawImageView) {
        _arrawImageView = [[UIImageView alloc]init];
    }
    return _arrawImageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
