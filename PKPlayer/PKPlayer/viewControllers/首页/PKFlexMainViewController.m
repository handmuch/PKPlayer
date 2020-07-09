//
//  PKFlexMainViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2019/11/4.
//  Copyright © 2019 PeterKwok. All rights reserved.
//

#import "PKFlexMainViewController.h"

@interface PKFlexMainViewController ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation PKFlexMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"flexTest";
    
    self.nameLabel.text = @"我是朱永正";
    // Do any additional setup after loading the view.
}



@end
