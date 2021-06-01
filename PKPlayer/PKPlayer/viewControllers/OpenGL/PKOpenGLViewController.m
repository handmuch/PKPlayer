//
//  PKOpenGLViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2021/5/17.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import "PKOpenGLViewController.h"
#import "PKOpenGLKitImageViewController.h"
#import "PKOpenGLSLViewController.h"

#import "PKMetalImageViewController.h"

//views
#import "PKMainViewTableViewCell.h"

@interface PKOpenGLViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *exampleTitleArray;

@end

@implementation PKOpenGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.exampleTitleArray = @[@"OpenGL渲染图片", @"OpenGL-GLSL渲染图片", @"Metal渲染图片"];
    [self setupUI];
}

- (void)setupUI {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exampleTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PKMainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PKMainViewTableViewCell class])
                                                                    forIndexPath:indexPath];
    cell.cellTitle = [self.exampleTitleArray objectAtIndex:indexPath.row];
    cell.imageName = @"main_local_file";
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        PKOpenGLKitImageViewController *openGLKitImageVC = [[PKOpenGLKitImageViewController alloc] init];
        [self.navigationController pushViewController:openGLKitImageVC animated:YES];
    }
    if (indexPath.row == 1) {
        PKOpenGLSLViewController *openGLSLVC = [[PKOpenGLSLViewController alloc] init];
        [self.navigationController pushViewController:openGLSLVC animated:YES];
    }
    if (indexPath.row == 2) {
        PKMetalImageViewController *metalImageVC = [[PKMetalImageViewController alloc] init];
        [self.navigationController pushViewController:metalImageVC animated:YES];
    }
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
        [_tableView registerClass:[PKMainViewTableViewCell class] forCellReuseIdentifier:NSStringFromClass([PKMainViewTableViewCell class])];
    }
    return _tableView;
}

@end
