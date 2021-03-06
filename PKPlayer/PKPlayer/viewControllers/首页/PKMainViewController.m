//
//  PKMainViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/29.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "PKMainViewController.h"
#import "PKLocalFileViewController.h"
#import "PKFlexMainViewController.h"
#import "PKFrameViewController.h"
#import "PKRecordViewController.h"
#import "AudioExportViewController.h"
#import "PKInterViewTestViewController.h"
#import "PKOpenGLViewController.h"

#import "PKMainViewTableViewCell.h"

static NSString *pkMainViewTableViewCellIndentifier = @"pkMainViewTableViewCellIndentifier";

@interface PKMainViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuTableView;

@property (nonatomic, copy) NSArray *mainImageNameArray;
@property (nonatomic, copy) NSArray *mainTitleArray;

@end

@implementation PKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self setupUI];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)initData {
    
    self.mainImageNameArray = @[@"main_local_file", @"main_local_image",  @"main_local_phone", @"main_local_music", @"main_local_file", @"main_local_file"];
    self.mainTitleArray = @[@"本地文件", @"照片库", @"录音功能", @"音频截取", @"Interview", @"OpenGL代码示例"];
    [self.menuTableView reloadData];
}

- (void)setupUI {
    
    self.title = @"PKPlayer";
    
    [self.view addSubview:self.menuTableView];
    [self.menuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mainTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PKMainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:pkMainViewTableViewCellIndentifier
                                                                    forIndexPath:indexPath];
    cell.cellTitle = [self.mainTitleArray objectAtIndex:indexPath.row];
    cell.imageName = [self.mainImageNameArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        PKLocalFileViewController *localFileViewController = [[PKLocalFileViewController alloc] init];
        [self.navigationController pushViewController:localFileViewController animated:YES];
    }
    if (indexPath.row == 1) {
        PKFrameViewController *frameViewController = [[PKFrameViewController alloc] init];
        [self.navigationController pushViewController:frameViewController animated:YES];
    }
    if (indexPath.row == 2) {
        PKRecordViewController *recordViewController = [[PKRecordViewController alloc] init];
        [self.navigationController pushViewController:recordViewController animated:YES];
    }
    if (indexPath.row == 3) {
        AudioExportViewController *audioExportViewController = [[AudioExportViewController alloc] init];
        [self.navigationController pushViewController:audioExportViewController animated:YES];
    }
    if (indexPath.row == 4) {
        PKInterViewTestViewController *interViewTestViewController = [[PKInterViewTestViewController alloc] init];
        [self.navigationController pushViewController:interViewTestViewController animated:YES];
    }
    if (indexPath.row == 5) {
        PKOpenGLViewController *openGLViewController = [[PKOpenGLViewController alloc] init];
        [self.navigationController pushViewController:openGLViewController animated:YES];
    }
}

#pragma mark - lazyInit

- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        [_menuTableView registerClass:[PKMainViewTableViewCell class]
               forCellReuseIdentifier:pkMainViewTableViewCellIndentifier];
    }
    return _menuTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
