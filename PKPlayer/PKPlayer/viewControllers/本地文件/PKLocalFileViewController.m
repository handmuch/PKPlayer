//
//  PKLocalFIleViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/30.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKLocalFileViewController.h"
#import "PKiTunesScanService.h"

@interface PKLocalFileViewController ()

@end

@implementation PKLocalFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"本地文件";
    [self getFile];

    [[PKiTunesScanService sharedInstance] starScaniTunesDocumentsAsynchronous];
    
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(fileChanageAction:)
                                                  name:pkFileScanNotificationDefine
                                                object:nil];
}

- (void)getFile {

    NSArray <NSString *> *fileArray = [[PKiTunesScanService sharedInstance] scanDocumentsFileList];
    for (NSString *fileName in fileArray) {
        
    }
}

- (void)fileChanageAction:(NSNotification *)notification
{
    // ZFileChangedNotification 通知是在子线程中发出的, 因此通知关联的方法会在子线程中执行
    NSLog(@"文件发生了改变, %@", [NSThread currentThread]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSError *error;
    // 获取指定路径对应文件夹下的所有文件
    NSArray <NSString *> *fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
    NSLog(@"%@", fileArray);
}

- (void)dealloc
{
    // 取消监听Document目录的文件改动
    [[PKiTunesScanService sharedInstance] stopMonitoringDocument];
    [[NSNotificationCenter defaultCenter] removeObserver:pkFileScanNotificationDefine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
