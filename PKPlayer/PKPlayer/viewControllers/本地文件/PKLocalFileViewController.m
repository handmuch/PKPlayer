//
//  PKLocalFIleViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/30.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKLocalFileViewController.h"
#import "PKiTunesScanService.h"

@interface PKLocalFileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *fileCollectionView;

@end

@implementation PKLocalFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"本地文件";
    [self setupUI];
    [self getFile];
    
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(fileChanageAction:)
                                                  name:pkFileScanNotificationDefine
                                                object:nil];
}

#pragma mark - private method

- (void)setupUI {
    
    [self.view addSubview:self.fileCollectionView];
    [self.fileCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)getFile {

    [[PKiTunesScanService sharedInstance] starScaniTunesDocumentsAsynchronous];
    NSArray <NSString *> *fileArray = [[PKiTunesScanService sharedInstance] scanDocumentsFileList];
    NSLog(@"%@",fileArray);
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

#pragma mark - lazyInit

- (UICollectionView *)fileCollectionView {
    if (!_fileCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //定义每个UICollectionView 横向的间距
        flowLayout.minimumLineSpacing = 12;
        //定义每个UICollectionView 纵向的间距
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(112, 188);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _fileCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _fileCollectionView.alwaysBounceVertical = YES;
        _fileCollectionView.showsVerticalScrollIndicator = YES;
        _fileCollectionView.backgroundColor = [UIColor clearColor];
        _fileCollectionView.delegate = self;
        _fileCollectionView.dataSource = self;
    }
    
    return _fileCollectionView;
}

@end
