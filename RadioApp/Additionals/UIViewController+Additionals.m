//
//  UIViewController+Additionals.m
//  RadioApp
//
//  Created by Pavel Gubin on 04.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "UIViewController+Additionals.h"

@implementation UIViewController (Additionals)

- (void) createEmptyLeftButton
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIBarButtonItem *btnEmpty = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = btnEmpty;
}

- (void) createLogo
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-more"]];
    imageView.frame = CGRectMake(0, 0, 85, 38);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
}

- (void) createBackButtonWithOpenMenu
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonMenuTapped)];
    btnBack.tintColor = colorWithRGB(0, 188, 228);
    self.navigationItem.leftBarButtonItem = btnBack;
}

- (void) createBackButton
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
    btnBack.tintColor = colorWithRGB(0, 188, 228);
    self.navigationItem.leftBarButtonItem = btnBack;
}

- (void) backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) backButtonMenuTapped
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [SHARED_DELEGATE.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
