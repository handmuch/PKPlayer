//
//  PKFrameViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2019/11/5.
//  Copyright © 2019 PeterKwok. All rights reserved.
//

#import "PKFrameViewController.h"
#import <FlexLib/FlexFrameView.h>

@interface PKFrameViewController ()

@end

@implementation PKFrameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    FlexFrameView* view = [[FlexFrameView alloc]initWithFlex:@"FrameVC" Frame:CGRectZero Owner:self];
    self.view = view;
}


@end
