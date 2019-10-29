//
//  PKSpectrumView.h
//  PKPlayer
//
//  Created by 郭建华 on 2019/5/13.
//  Copyright © 2019 PeterKwok. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKSpectrumView : UIView

@property (nonatomic, strong) NSMutableArray <NSArray<NSNumber *> *> *speatra;

@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, assign) CGFloat space;

@end

NS_ASSUME_NONNULL_END
