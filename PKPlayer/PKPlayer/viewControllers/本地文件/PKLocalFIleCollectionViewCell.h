//
//  PKLocalFIleCollectionViewCell.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/5/4.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKFileModel.h"

static NSString *PKLocalFileCollectionViewCellIndentifier = @"PKLocalFileCollectionViewCellIndentifier";

@interface PKLocalFileCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) PKFileModel *file;

+ (CGSize)localFileCollectionViewCellSize;

@end
