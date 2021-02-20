//
//  PKLocalFIleViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/30.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKLocalFileViewController.h"

//views
#import "PKLocalFileCollectionViewCell.h"
#import "PKSpectrumView.h"

//services
#import "PKiTunesScanService.h"
#import "PKAudioWaveDisplayPlayer.h"
//models
#import "PKFileModel.h"

#define ARRAY_SIZE(x) (sizeof(x)/sizeof((x)[0]))

@interface PKLocalFileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PKAudioSpectrumPlayerDelegate>

@property (nonatomic, strong) UICollectionView *fileCollectionView;
@property (nonatomic, strong) PKSpectrumView *spectrumView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) PKAudioWaveDisplayPlayer *audioPlayer;

@property (nonatomic, strong) UIImpactFeedbackGenerator *generator;
@property (nonatomic, assign) NSInteger count;


@end

@implementation PKLocalFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"本地文件";
    self.count = 0;
    [self setupUI];
    [self getFile];
    
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(fileChanageAction:)
                                                  name:pkFileScanNotificationDefine
                                                object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat barSpace = self.spectrumView.frame.size.width / (CGFloat)(self.audioPlayer.analyzer.frequencyBands * 3 - 1);
    self.spectrumView.barWidth = barSpace * 2;
    self.spectrumView.space = barSpace;
}

#pragma mark - private method

- (void)setupUI {
    
    if (@available(iOS 11.0, *)) {
        self.fileCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.spectrumView];
    [self.spectrumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.left.right.equalTo(self.view).offset(0);
        make.height.mas_equalTo(150);
    }];
    
    [self.view addSubview:self.fileCollectionView];
    [self.fileCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(214, 0, 0, 0));
    }];
}

- (void)getFile {

    [[PKiTunesScanService sharedInstance] starScaniTunesDocumentsAsynchronous];
    NSArray <PKFileModel *> *fileArray = [[PKiTunesScanService sharedInstance] scanDocumentsFileList];
    self.dataSource = [NSMutableArray arrayWithArray:fileArray];
    [self.fileCollectionView reloadData];
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
}

- (void)dealloc
{
    // 取消监听Document目录的文件改动
    [[PKiTunesScanService sharedInstance] stopMonitoringDocument];
    [[NSNotificationCenter defaultCenter] removeObserver:pkFileScanNotificationDefine];
    
    [self.audioPlayer stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PKLocalFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PKLocalFileCollectionViewCellIndentifier forIndexPath:indexPath];
    cell.file = [self.dataSource objectAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [PKLocalFileCollectionViewCell localFileCollectionViewCellSize];
}

#pragma mark - UICollection delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PKFileModel *file = [self.dataSource objectAtIndex:indexPath.item];
    [self.audioPlayer playWithFilePath:file.filePath];
}

#pragma mark - PKAudioSpectrumPlayerDelegate

- (void)player:(PKAudioWaveDisplayPlayer *)player didGenerateSpectrum:(NSMutableArray *)specturm {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.spectrumView.speatra = specturm;
            NSArray *spectraLeft = specturm.firstObject;
            CGFloat amplitude = [[spectraLeft objectAtIndex:0] floatValue];
            if (specturm.count >= 2) {
                NSArray *spectraRight = [specturm objectAtIndex:1];
                amplitude += [[spectraRight objectAtIndex:0] floatValue];
                amplitude = amplitude/2;
            }
            self.count++;
            if (@available(iOS 13.0, *)) {
                CGFloat realAmplitude = amplitude*1.7;
                if (realAmplitude < 0.4) {
                    return;
                }
                [self.generator impactOccurredWithIntensity:realAmplitude];
            }
        });
    }
}

#pragma mark - lazyInit

- (UICollectionView *)fileCollectionView {
    if (!_fileCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //定义每个UICollectionView 横向的间距
        flowLayout.minimumLineSpacing = 12;
        //定义每个UICollectionView 纵向的间距
        flowLayout.minimumInteritemSpacing = 12;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _fileCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _fileCollectionView.alwaysBounceVertical = YES;
        _fileCollectionView.showsVerticalScrollIndicator = YES;
        _fileCollectionView.backgroundColor = [UIColor clearColor];
        _fileCollectionView.delegate = self;
        _fileCollectionView.dataSource = self;
        
        [_fileCollectionView registerClass:[PKLocalFileCollectionViewCell class]
                forCellWithReuseIdentifier:PKLocalFileCollectionViewCellIndentifier];
    }
    
    return _fileCollectionView;
}

- (PKAudioWaveDisplayPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[PKAudioWaveDisplayPlayer alloc]init];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (PKSpectrumView *)spectrumView {
    if (!_spectrumView) {
        _spectrumView = [[PKSpectrumView alloc]initWithFrame:CGRectZero];
    }
    return _spectrumView;
}

- (UIImpactFeedbackGenerator *)generator {
    if (!_generator) {
        _generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    }
    return _generator;
}

@end
