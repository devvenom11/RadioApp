//
//  BaseViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 12.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.view removeGestureRecognizer:self.navigationController.interactivePopGestureRecognizer];
    SHARED_DELEGATE.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
