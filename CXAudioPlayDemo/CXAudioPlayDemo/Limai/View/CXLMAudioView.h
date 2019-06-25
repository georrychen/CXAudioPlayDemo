//
//  CXLMAudioView.h
//  CXAudioPlayDemo
//
//  Created by Xu Chen on 2019/6/25.
//  Copyright © 2019 xu.yzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXLMAudioView : UIView

@property (weak, nonatomic) IBOutlet UIView *audioPlayView;
@property (weak, nonatomic) IBOutlet UIButton *audio_playButton;
@property (weak, nonatomic) IBOutlet UILabel *audio_currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *audio_totoalTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *audio_slider;
/*! 进度条y轴居中约束，默认为0，开始播放时，为 -5 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audio_slider_centerYCons;

/**
 销毁播放器
 */
- (void)distroyAudioPlayer;

- (void)updateViewWithData:(id)data;

@end

