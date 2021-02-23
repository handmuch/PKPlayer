//
//  AudioExportViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2021/2/9.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import "AudioExportViewController.h"

#import "PKFileDefine.h"

#import "AuidoTableViewCell.h"

#import "PKiTunesScanService.h"
#import "TVBVideoMusicExportSession.h"

@interface AudioExportViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign, readwrite) NSTimeInterval playingTime;
@property (nonatomic, assign) CGFloat playingProgress;
@property (nonatomic, strong) NSTimer *playTimer;

@end

@implementation AudioExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self loadMediaDataSource];
}

- (void)setupUI {
    [self.view addSubview: self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - loadData

- (void)loadMediaDataSource {
    [[PKiTunesScanService sharedInstance] starScaniTunesDocumentsAsynchronous];
    NSArray <PKFileModel *> *fileArray = [[PKiTunesScanService sharedInstance] scanDocumentsFileList];
    self.dataSource = [NSMutableArray arrayWithArray:fileArray];
    [self.tableView reloadData];
}

#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AuidoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AuidoTableViewCell class]) forIndexPath:indexPath];
    cell.fileModel = [self.dataSource objectAtIndex:indexPath.row];
    __weak __typeof(cell) weakCell = cell;
    cell.videoOpMusicPlay = ^(PKFileModel * _Nonnull fileModel) {
        __strong __typeof(cell) strongCell = weakCell;
        TVBVideoMusicExportSession *exportSeesion = [[TVBVideoMusicExportSession alloc] initWithUrl:[NSURL fileURLWithPath:fileModel.filePath]];
        exportSeesion.outputPath = [NSURL fileURLWithPath:[PKFileDefine exportOpMusicfileName:fileModel.fileName]];
        exportSeesion.timeRang = CMTimeRangeMake(kCMTimeZero, CMTimeMake(100, 1));
        [exportSeesion exportAsynchronouslyWithCompletionHandler:^(NSURL * _Nonnull outputUrl) {
            [strongCell playAudioWithUrl:outputUrl];
        } error:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    };
    cell.videoEdMusicPlay = ^(PKFileModel * _Nonnull fileModel) {
        
    };
    return cell;
}

#pragma mark - lazyInit

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.estimatedRowHeight = 60;
        _tableView.separatorInset = UIEdgeInsetsZero;
        [_tableView registerClass:[AuidoTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AuidoTableViewCell class])];
    }
    return _tableView;
}

@end
