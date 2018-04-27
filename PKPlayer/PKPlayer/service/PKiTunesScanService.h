//
//  PKiTunesScanService.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/30.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKiTunesScanService : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)scanDocumentsFileList;

- (void)starScaniTunesDocumentsAsynchronous;

- (void)startScaningDirectory:(NSString *)directoryPath;

- (void)stopMonitoringDocument;

@end
