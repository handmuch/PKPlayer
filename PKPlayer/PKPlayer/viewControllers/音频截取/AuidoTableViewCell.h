//
//  AuidoTableViewCell.h
//  PKPlayer
//
//  Created by 郭建华 on 2021/2/9.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AuidoTableViewCell : UITableViewCell

@property (nonatomic, strong) PKFileModel *fileModel;

@property (nonatomic, copy) void(^videoOpMusicPlay)(PKFileModel *fileModel);

@property (nonatomic, copy) void(^videoEdMusicPlay)(PKFileModel *fileModel);

- (void)playAudioWithUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
