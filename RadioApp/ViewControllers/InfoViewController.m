//
//  InfoViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 08.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "InfoViewController.h"
#import "UIImage+Resize.h"
#import "InfoViewAddition.h"
#import <MessageUI/MessageUI.h>


@interface InfoViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIImageView *imageViewIcon;
    __weak IBOutlet UILabel *labelDescription;
    __weak IBOutlet UIView *viewSeparator1;
    __weak IBOutlet UIView *viewAddress;
    __weak IBOutlet UILabel *labelAddress;
    
    InfoViewAddition *viewPhone;
    InfoViewAddition *viewEmail;
}

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLogo];
    [self createBackButton];
    
    viewPhone = [InfoViewAddition loadView];
    [viewPhone.buttonCall addTarget:self action:@selector(callTapped) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:viewPhone];
    
    viewEmail = [InfoViewAddition loadView];
    [viewEmail.buttonCall addTarget:self action:@selector(emailTapped) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:viewEmail];

    [self setupUI];
    
    SHARED_DELEGATE.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;

    if (self.needCreateLogo)
    {
        for (UIView *view in self.view.subviews)
        {
            CGRect frame = view.frame;
            frame.origin.y += 64;
            view.frame = frame;
        }
    
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-more"]];
        imageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 85) / 2, 23, 85, 38);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 1)];
        view.backgroundColor = [UIColor darkGrayColor];
        view.alpha = 0.2;
        [self.view addSubview:view];
        
        UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBack.frame = CGRectMake(3, 20, 40, 40);
        [btnBack addTarget:self action:@selector(showCenterScreen) forControlEvents:UIControlEventTouchUpInside];
        [btnBack setImage:[UIImage imageNamed:@"arrow-back"] forState:UIControlStateNormal];
        [self.view addSubview:btnBack];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUI) name:kNotifDidUpateLanguage object:nil];
}

- (void) showCenterScreen
{
    [SHARED_DELEGATE.drawerController closeDrawerAnimated:YES completion:nil];
}

- (void) setupUI
{
    labelAddress.text = LocalizedString(@"contact_address");
    
    labelTitle.text = [self.itemInfo[@"name"] uppercaseString];
    
    NSArray *colors = [self.itemInfo[@"color"] componentsSeparatedByString:@","];
    
    if (colors.count >= 3)
    {
        float r = [colors[0] floatValue];
        float g = [colors[1] floatValue];
        float b = [colors[2] floatValue];
        
        labelTitle.backgroundColor = colorWithRGB(r, g, b);
    }

    NSString *logoPath = self.itemInfo[@"logo"];
    
    if ([logoPath rangeOfString:@"morefmcover"].location != NSNotFound)
    {
        imageViewIcon.image = [[UIImage imageNamed:@"NoCover"] resizedImage:CGSizeMake(60, 60) interpolationQuality:kCGInterpolationHigh];
    }
    else if ([logoPath rangeOfString:@"jazzcover"].location != NSNotFound)
    {
        imageViewIcon.image = [[UIImage imageNamed:@"jazzcover"] resizedImage:CGSizeMake(60, 60) interpolationQuality:kCGInterpolationHigh];
    }
    else if ([logoPath rangeOfString:@"90scover"].location != NSNotFound)
    {
        imageViewIcon.image = [[UIImage imageNamed:@"90scover"] resizedImage:CGSizeMake(60, 60) interpolationQuality:kCGInterpolationHigh];
    }
    else
    {
        [imageViewIcon sd_setImageWithURL:[NSURL URLWithString:self.itemInfo[@"logo"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (image)
            {
                image = [image resizedImage:CGSizeMake(60, 60) interpolationQuality:kCGInterpolationHigh];
                imageViewIcon.image = image;
            }
        }];
    }

    
    NSString *description = nil;
    
    if ([[DataManager getCurrentLanguageIdentifier] isEqualToString:languageEnIdentifier])
    {
        description = self.itemInfo[@"description_en"];
    }
    else if ([[DataManager getCurrentLanguageIdentifier] isEqualToString:languageUAIdentifier])
    {
        description = self.itemInfo[@"description_ua"];
    }
    else
    {
        description = self.itemInfo[@"description_ru"];
    }
    
    labelDescription.text = description;
    
    CGRect frame = labelDescription.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width - frame.origin.x - 15;
    frame.size.height = [labelDescription.text heightWithFont:labelDescription.font maxWidth:frame.size.width];
    labelDescription.frame = frame;
    
    frame = viewSeparator1.frame;
    frame.origin.y = MAX(imageViewIcon.frame.origin.y + imageViewIcon.frame.size.height + 15, labelDescription.frame.origin.y + labelDescription.frame.size.height + 15);
    viewSeparator1.frame = frame;
    
    viewPhone.labelPhone.text = self.itemInfo[@"phone"];
    viewPhone.labelTitle.text = LocalizedString(@"Размещение рекламы:");
    
    frame = viewPhone.labelTitle.frame;
    frame.origin.y = 18;
    frame.size.height = 21;
    viewPhone.labelTitle.frame = frame;
    
    frame = viewPhone.labelPhone.frame;
    frame.origin.y = 41;
    viewPhone.labelPhone.frame = frame;
    
    frame = viewPhone.frame;
    frame.origin.y = viewSeparator1.frame.origin.y + viewSeparator1.frame.size.height;
    viewPhone.frame = frame;
    
    viewEmail.labelPhone.text = [NSString stringWithFormat:@"%@\n%@",LocalizedString(@"Елена Борисенко"), self.itemInfo[@"email"]];
    viewEmail.labelPhone.numberOfLines = 2;
    
    frame = viewEmail.labelPhone.frame;
    frame.origin.y = 30;
    frame.size.height = [viewEmail.labelPhone.text heightWithFont:viewEmail.labelPhone.font maxWidth:viewEmail.labelPhone.frame.size.width];
    viewEmail.labelPhone.frame = frame;
   
    frame = viewEmail.labelTitle.frame;
    frame.origin.y = 7;
    viewEmail.labelTitle.frame = frame;
    
    viewEmail.imageViewIcon.image = [UIImage imageNamed:@"contacts-mail-icon"];
    viewEmail.labelTitle.text = LocalizedString(@"Предложения, сотрудничество:");
    
    frame = viewEmail.frame;
    frame.origin.y = viewPhone.frame.origin.y + viewPhone.frame.size.height;
    viewEmail.frame = frame;
    
    frame = viewAddress.frame;
    frame.origin.y = viewEmail.frame.origin.y + viewEmail.frame.size.height;
    viewAddress.frame = frame;
    
    if ([[AudioManager sharedManager].audioLinkPath rangeOfString:@"odrex"].location != NSNotFound ||
        [[AudioManager sharedManager].audioLinkPath rangeOfString:@"fratelli"].location != NSNotFound)
    {
        viewPhone.labelTitle.text = LocalizedString(@"Корпоративная радиостанция для вашего бизнеса:");
        viewPhone.labelTitle.numberOfLines = 2;
        
        frame = viewPhone.labelTitle.frame;
        frame.size.height = [viewPhone.labelTitle.text heightWithFont:viewPhone.labelTitle.font maxWidth:viewPhone.labelTitle.frame.size.width];
        frame.origin.y = (viewPhone.frame.size.height - frame.size.height -  viewPhone.labelPhone.frame.size.height - 5) / 2;
        viewPhone.labelTitle.frame = frame;
    
        frame = viewPhone.labelPhone.frame;
        frame.origin.y = viewPhone.labelTitle.frame.origin.y + viewPhone.labelTitle.frame.size.height + 5;
        viewPhone.labelPhone.frame = frame;

        viewAddress.hidden = YES;
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, viewEmail.frame.origin.y + viewEmail.frame.size.height);
    }
    else
    {
        viewAddress.hidden = NO;
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, viewAddress.frame.origin.y + viewAddress.frame.size.height);
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) emailTapped
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setToRecipients:@[self.itemInfo[@"email"]]];
        mailController.mailComposeDelegate = self;
        [self presentViewController:mailController animated:YES completion:nil];
    }
    else
    {
        [UIAlertView showTitleInAlertView:LocalizedString(@"Вы не можете отправить email")];
    }

}

- (void) callTapped
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Вы действительно хотите позвонить?") message:nil delegate:self cancelButtonTitle:LocalizedString(@"Отмена") otherButtonTitles:LocalizedString(@"Позвонить"), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *phoneNumber = self.itemInfo[@"phone"];
        
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]];
        
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
        else
        {
            [UIAlertView showTitleInAlertView:LocalizedString(@"Вы не можете позвонить с данного устройства")];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
