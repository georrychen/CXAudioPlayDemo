//
//  CXLimaiViewController.m
//  CXAudioPlayDemo
//
//  Created by Xu Chen on 2019/6/25.
//  Copyright © 2019 xu.yzl. All rights reserved.
//

#import "CXLimaiViewController.h"
#import "CXLMAudioView.h"

@interface CXLimaiViewController ()
@property (nonatomic, strong) CXLMAudioView *mainView;

@end

@implementation CXLimaiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mainView];
}

- (CXLMAudioView *)mainView {
    if (!_mainView) {
        _mainView = (CXLMAudioView *)[[NSBundle mainBundle] loadNibNamed:@"CXLMAudioView" owner:nil options:nil].lastObject;
        _mainView.frame = CGRectMake(0, 100, self.view.bounds.size.width, 60);
    }
    return _mainView;
}


@end
