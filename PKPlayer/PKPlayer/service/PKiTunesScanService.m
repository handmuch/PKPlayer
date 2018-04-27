//
//  PKiTunesScanService.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/30.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKiTunesScanService.h"

@interface PKiTunesScanService (){
    
    dispatch_queue_t _pkScanQueue;
    dispatch_source_t _pkScanSource;
}

@end

@implementation PKiTunesScanService

+ (instancetype)sharedInstance {
    static id aInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aInstance = [[self alloc] init];
    });
    return aInstance;
}

#pragma mark - public method

- (NSArray *)scanDocumentsFileList {
    // ZFileChangedNotification 通知是在子线程中发出的, 因此通知关联的方法会在子线程中执行
    NSLog(@"文件发生了改变, %@", [NSThread currentThread]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSError *error;
    // 获取指定路径对应文件夹下的所有文件
    NSArray <NSString *> *fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
    NSLog(@"%@", fileArray);
    return fileArray;
}

//开始监听Document目录文件改动
- (void)starScaniTunesDocumentsAsynchronous {
    
    // 获取沙盒的Document目录
    NSString *docuPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    [self startScaningDirectory:docuPath];
}

- (void)startScaningDirectory:(NSString *)directoryPath {
    
    // 创建 file descriptor (需要将NSString转换成C语言的字符串)
    // open() 函数会建立 file 与 file descriptor 之间的连接
    int filedes = open([directoryPath cStringUsingEncoding:NSASCIIStringEncoding], O_EVTONLY);
    // 创建 dispatch queue, 当文件改变事件发生时会发送到该 queue
    _pkScanQueue = dispatch_queue_create("pkFileMonitorQueue", 0);
    // 创建 GCD source. 将用于监听 file descriptor 来判断是否有文件写入操作
    _pkScanSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, filedes, DISPATCH_VNODE_WRITE, _pkScanQueue);
    // 当文件发生改变时会调用该 block
    dispatch_source_set_event_handler(_pkScanSource, ^{
        // 在文件发生改变时发出通知
        // 在子线程发送通知, 这个通知触发的方法会在子线程当中执行
        [[NSNotificationCenter defaultCenter] postNotificationName:pkFileScanNotificationDefine object:nil userInfo:nil];
    });
    // 当文件监听停止时会调用该 block
    dispatch_source_set_cancel_handler(_pkScanSource, ^{
        // 关闭文件监听时, 关闭该 file descriptor
        close(filedes);
    });
    // 开始监听文件
    dispatch_resume(_pkScanSource);
}

// 停止监听指定目录的文件改动
- (void)stopMonitoringDocument {
    
    dispatch_cancel(_pkScanSource);
}


@end
