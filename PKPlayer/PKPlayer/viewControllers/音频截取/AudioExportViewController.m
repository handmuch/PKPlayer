//
//  AudioExportViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2021/2/9.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import "AudioExportViewController.h"

#import "AuidoTableViewCell.h"

#import "PKiTunesScanService.h"

@interface AudioExportViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

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
        [_tableView registerClass:[AuidoTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AuidoTableViewCell class])];
    }
    return _tableView;
}

@end
