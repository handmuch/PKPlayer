//
//  PKInterViewTestViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2021/4/21.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import "PKInterViewTestViewController.h"

@interface PKInterViewTestViewController ()

@end

@implementation PKInterViewTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self GDCOperationTest];
}

- (void)GDCOperationTest {
    dispatch_queue_t queue = dispatch_queue_create("com.pkInterview.queue", DISPATCH_QUEUE_SERIAL);
    __block int i = 0;
    dispatch_async(queue, ^{
        for (i; i < 100; i++) {
            NSLog(@"========>%ld", i);
        }
    });
    NSLog(@"=========>%ld", i++);
}

@end
