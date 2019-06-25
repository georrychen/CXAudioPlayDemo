//
//  CXLMAudioView.m
//  CXAudioPlayDemo
//
//  Created by Xu Chen on 2019/6/25.
//  Copyright © 2019 xu.yzl. All rights reserved.
//

#import "CXLMAudioView.h"
#import <AVFoundation/AVFoundation.h>

@interface CXLMAudioView ()
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) NSString *audioPlayerUrlString;
@end

@implementation CXLMAudioView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.audioPlayerUrlString = @"";
    
    // 播放器边框
    self.audioPlayView.layer.borderWidth = 1;
    self.audioPlayView.layer.borderColor = [UIColor colorWithRed:255/255.0 green:196/255.0 blue:0/255.0 alpha:1.0].CGColor;
    self.audioPlayView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.audioPlayView.layer.cornerRadius = 4;
    
    UIImage *slideIamge= [self imageWithColor:[UIColor orangeColor]];
    slideIamge = [self cx_addCornerWithRadius:5 size:slideIamge.size image:slideIamge];
    // 设置滑块图片, 修改默认滑块，默认的太大了
    [self.audio_slider setThumbImage:slideIamge forState:UIControlStateNormal];
    [self.audio_slider setThumbImage:slideIamge forState:UIControlStateHighlighted];
    // 如果设置YES，在拖动滑块的任何时候，滑块的值都会改变。默认设置为YES
    [self.audio_slider setContinuous:NO];
}


- (void)updateViewWithData:(id)data {
    // 音频
//    if (trip_isEmptyStringFunction(dict[@"audioUrl"])) {
//        self.audioViewHeight = -23;
//        self.audioUrlStr = @"";
//    } else {
//        self.audioViewHeight = 58;
//        self.audioUrlStr = dict[@"audioUrl"];
//    }
    
    // 音频
//    self.audioViewHeightCons.constant = viewModel.audioViewHeight;
//    self.audioViewHeightCons.constant = 58;
//    if (viewModel.audioViewHeight > 0) { // 可以播放
//        self.audioPlayerUrlString = viewModel.audioUrlStr;
//        [self configureAudioPlayer:viewModel.audioUrlStr];
//        self.audioPlayView.hidden = NO;
//    } else {
//        self.audioPlayView.hidden = YES;
//    }
    
    self.audioPlayerUrlString = @"";
    [self configureAudioPlayer:self.audioPlayerUrlString];

    
}


// MARK: xu --------- 点播播放按钮

- (IBAction)audioButtonClicked:(id)sender {
    // 判断播放视图是否为播放状态
    if (self.audio_currentTimeLabel.hidden) {
        self.audio_currentTimeLabel.hidden = NO;
        self.audio_totoalTimeLabel.hidden = NO;
        self.audio_slider_centerYCons.constant = -5;
        
        self.audio_currentTimeLabel.alpha = 0;
        self.audio_totoalTimeLabel.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.audio_currentTimeLabel.alpha = 1;
            self.audio_totoalTimeLabel.alpha = 1;
            [self layoutIfNeeded];
        }];
    }
    self.audio_playButton.selected = !self.audio_playButton.selected;
    if (self.audio_playButton.selected) { // 正在播放中
        [self.audio_playButton setImage:[UIImage imageNamed:@"ic_learn_pause"] forState:UIControlStateNormal];
        if (!self.audioPlayer) {
            [self configureAudioPlayer:self.audioPlayerUrlString];
        }
        [self.audioPlayer play];
    } else { // 暂停、未开始播放
        [self.audio_playButton setImage:[UIImage imageNamed:@"ic_learn_play"] forState:UIControlStateNormal];
        [self.audioPlayer pause];
    }
}


// MARK: - 配置音频播放器

- (void)configureAudioPlayer:(NSString *)urlString {
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.audioPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    // 当前时间
    self.audio_currentTimeLabel.text = @"00:00";
    // 总时间
//    self.audio_totoalTimeLabel.text = [BDMUtility stringByCMTime:item.duration];
    self.audio_totoalTimeLabel.text = @"10:00";
    
    // 监听播放器的状态（KVO）
    [self.audioPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听音乐的缓存进度（监听AVPlayer的loadedTimeRanges属性）
    [self.audioPlayer addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.audioPlayer.currentItem];
    
    // 音乐播放进度（AVPlayer提供了方法）
    [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 当前播放的时间
        float current = CMTimeGetSeconds(time);
        // 总时间
        float total = CMTimeGetSeconds(item.duration);
        if(current) {
            float progress = current / total;
            // 更新播放进度条
            self.audio_slider.value = progress;
            self.audio_currentTimeLabel.text = @"00:00";
            self.audio_totoalTimeLabel.text =  @"10:00";
//            self.audio_currentTimeLabel.text = [BDMUtility stringByCMTime:time];
//            self.audio_totoalTimeLabel.text = [BDMUtility stringByCMTime:item.duration];
        }
    }];
    
    // slider开始滑动事件
    [self.audio_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.audio_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.audio_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
}

// MARK: - 滑杆滑动响应事件
/*
 *  progressSliderTouchBegan
 */
- (void)progressSliderTouchBegan:(UISlider *)slider {
    if (self.audioPlayer) {
        [self.audioPlayer pause];
    }
}

/*
 *  progressSliderValueChanged
 */
- (void)progressSliderValueChanged:(UISlider *)slider {
    float total = CMTimeGetSeconds(self.audioPlayer.currentItem.duration);
    float current = total * slider.value;
//    self.audio_currentTimeLabel.text = [BDMUtility stringBySecond:current];
    self.audio_currentTimeLabel.text = @"11:00";
}

/*
 *  progressSliderTouchEnded
 */
- (void)progressSliderTouchEnded:(UISlider *)slider {
    if (self.audioPlayer) {
        // 计算时间
        float time = slider.value * CMTimeGetSeconds(self.audioPlayer.currentItem.duration);
        // 跳转到指定时间
        [self.audioPlayer seekToTime:CMTimeMake(time, 1)];
        
        [self.audioPlayer play];
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if([keyPath isEqualToString:@"status"]) {
        switch (self.audioPlayer.status) {
            case AVPlayerItemStatusUnknown: // 未知状态
            {
//                [BDMProgressHUD cx_showErrorTipMessage:@"音频文件加载失败！"];
            }
                break;
            case AVPlayerItemStatusReadyToPlay: // 准备播放
            {
                
            }
                break;
            case AVPlayerItemStatusFailed: // 加载失败
            {
//                [BDMProgressHUD cx_showErrorTipMessage:@"音频文件加载失败！"];
            }
                break;
            default:
                break;
        }
    }
    
    if([keyPath isEqualToString:@"loadedTimeRanges"]) { // 缓冲
        //        NSArray * timeRanges = self.audioPlayer.currentItem.loadedTimeRanges;
        //        //本次缓冲的时间范围
        //        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        //        //缓冲总长度
        //        NSTimeInterval totalLoadTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //        //音乐的总时间
        //        NSTimeInterval duration = CMTimeGetSeconds(self.audioPlayer.currentItem.duration);
        //        //计算缓冲百分比例
        //        NSTimeInterval scale = totalLoadTime/duration;
        //更新缓冲进度条
        //        self.topLineWidthCons.constant += scale * self.audio_topLineMaxWidth;
        //        [UIView animateWithDuration:0.3 animations:^{
        //            [self layoutIfNeeded];
        //        }];
    }
}

/**
 音频播放结束
 */
- (void)audioPlayEnd {
    if (self.audioPlayer) {
        // 移除观察者
        [self.audioPlayer removeObserver:self forKeyPath:@"status"];
        [self.audioPlayer removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.audioPlayer pause];
        self.audioPlayer = nil;
        
        // 重置播放器视图状态
        self.audio_playButton.selected = NO;
        [self.audio_playButton setImage:[UIImage imageNamed:@"ic_learn_play"] forState:UIControlStateNormal];
        self.audio_slider_centerYCons.constant = 0;
        self.audio_currentTimeLabel.text = @"00:00";
        [UIView animateWithDuration:0.3 animations:^{
            self.audio_currentTimeLabel.alpha = 0;
            self.audio_totoalTimeLabel.alpha = 0;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.audio_currentTimeLabel.hidden = YES;
            self.audio_totoalTimeLabel.hidden = YES;
        }];
    }
}


- (void)distroyAudioPlayer {
    [self audioPlayEnd];
}




// MARK: xu --------- Other

// 图片切圆角
- (UIImage*)cx_addCornerWithRadius:(CGFloat)radius size:(CGSize)size image:(UIImage *)img {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    [img drawInRect:rect];
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// 根据颜色绘制一个图片出来
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 16.0f, 16.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
