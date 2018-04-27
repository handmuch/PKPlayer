//
//  ViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2018/3/29.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import "ViewController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

#define playViewTop 60
#define playViewHeightScale 0.5625

@interface ViewController ()

@property (nonatomic, copy) NSString *hlsUrl;
@property (nonatomic, strong) id <IJKMediaPlayback> player;

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIButton *controlButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
}

- (void)setupUI {
    
    self.hlsUrl = [NSString stringWithFormat:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.hlsUrl]
                                                             withOptions:nil];
    UIView *playView = [self.player view];
    playView.frame = self.playerView.bounds;
    [self.playerView addSubview:playView];
    [self.view addSubview:self.playerView];
}

-(void)viewWillAppear:(BOOL)animated{
    if (![self.player isPlaying]) {
        [self.player prepareToPlay];
        [self.player play];
    }
}

#pragma mark - lazyInit

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc]initWithFrame:CGRectMake(0, playViewTop, self.view.bounds.size.width, self.view.bounds.size.width * playViewHeightScale)];
        _playerView.backgroundColor = [UIColor blackColor];
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return _playerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
