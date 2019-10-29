//
//  PKiTunesScanService.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/30.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKFileModel;

@interface PKiTunesScanService : NSObject

+ (instancetype)sharedInstance;

- (NSArray <PKFileModel *>*)scanDocumentsFileList;

- (void)starScaniTunesDocumentsAsynchronous;

- (void)startScaningDirectory:(NSString *)directoryPath;

- (void)stopMonitoringDocument;

@end
