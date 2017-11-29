//
//  CorporativeViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 05.08.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "CorporativeViewController.h"
#import <MessageUI/MessageUI.h>
#import "MainViewController.h"

@interface CorporativeViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelDescription;
    __weak IBOutlet UIView *viewSeparator;
    __weak IBOutlet UIImageView *imageViweIconCup;
    __weak IBOutlet UILabel *labelDescription2;
    __weak IBOutlet UIView *viewSeparator2;
    __weak IBOutlet UIView *viewAdditional1;
    __weak IBOutlet UILabel *labelAnonse;
    __weak IBOutlet UILabel *labelSuccessCorporation;
    __weak IBOutlet UIView *viewAdditional2;
    __weak IBOutlet UIImageView *imageViewOdrex;
    __weak IBOutlet UIImageView *imageViewFratel;
    __weak IBOutlet UIButton *buttonOdrex;
    __weak IBOutlet UIButton *buttonFratel;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CorporativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createLogo];
    [self createBackButtonWithOpenMenu];

    labelTitle.text = LocalizedString(@"Корпоративное радио");
    labelDescription2.text = LocalizedString(@"corporative_description2");
    labelAnonse.text = LocalizedString(@"Узнай все подробности:");
    labelSuccessCorporation.text = LocalizedString(@"Примеры успешно реализованных корпоративных радиостанций");
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"corporative_description") attributes:@{NSFontAttributeName : labelDescription.font}];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:[LocalizedString(@"corporative_description") rangeOfString:LocalizedString(@"corporative_description_part")]];
    
    labelDescription.attributedText = attr;
    
    CGRect frame = labelDescription.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width - frame.origin.x - 15;
    frame.size.height = ceilf([attr boundingRectWithSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height);
    labelDescription.frame = frame;
    
    frame = viewSeparator.frame;
    frame.origin.y = labelDescription.frame.origin.y + labelDescription.frame.size.height + 15;
    viewSeparator.frame = frame;
    
    frame = imageViweIconCup.frame;
    frame.origin.y = viewSeparator.frame.origin.y + 15;
    imageViweIconCup.frame = frame;
    
    frame = labelDescription2.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width - frame.origin.x - 15;
    frame.size.height = [labelDescription2.text heightWithFont:labelDescription2.font maxWidth:frame.size.width];
    frame.origin.y = imageViweIconCup.frame.origin.y - 4;
    labelDescription2.frame = frame;
    
    frame = viewSeparator2.frame;
    frame.origin.y = labelDescription2.frame.origin.y + labelDescription2.frame.size.height + 15;
    viewSeparator2.frame = frame;
    
    frame = viewAdditional1.frame;
    frame.origin.y = viewSeparator2.frame.origin.y + 15;
    viewAdditional1.frame = frame;

    frame = viewAdditional2.frame;
    frame.origin.y = viewAdditional1.frame.origin.y + viewAdditional1.frame.size.height + 15;
    viewAdditional2.frame = frame;

    if (is_IPHONE_6)
    {
        frame = imageViewOdrex.frame;
        frame.origin.x += 20;
        imageViewOdrex.frame = frame;
        
        frame = imageViewFratel.frame;
        frame.origin.x += 35;
        imageViewFratel.frame = frame;
        
    }
    else if (is_IPHONE_6_PLUS)
    {
        frame = imageViewOdrex.frame;
        frame.origin.x += 40;
        imageViewOdrex.frame = frame;
        
        frame = imageViewFratel.frame;
        frame.origin.x += 55;
        imageViewFratel.frame = frame;
    }
    
    buttonOdrex.frame = imageViewOdrex.frame;
    buttonFratel.frame = imageViewFratel.frame;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, viewAdditional2.frame.origin.y + viewAdditional2.frame.size.height);
}

- (IBAction)odrexTapped:(id)sender {
    
    NSDictionary *item = nil;
 
    for (NSDictionary *_item in SHARED_DELEGATE.visibleStations)
    {
        if ([_item[@"link256"] rangeOfString:@"odrex"].location != NSNotFound)
        {
            item = _item;
            break;
        }
    }
    
    if (item)
    {
        MainViewController *mainController = self.navigationController.viewControllers[0];
        [mainController stationDidSelectWithItem:item];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)fratelTapped:(id)sender {
    NSDictionary *item = nil;
    
    for (NSDictionary *_item in SHARED_DELEGATE.visibleStations)
    {
        if ([_item[@"link256"] rangeOfString:@"fratelli"].location != NSNotFound)
        {
            item = _item;
        }
    }
    
    if (item)
    {
        MainViewController *mainController = self.navigationController.viewControllers[0];
        [mainController stationDidSelectWithItem:item];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)mailTapped:(id)sender {

    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setToRecipients:@[@"more@more.fm"]];
        mailController.mailComposeDelegate = self;
        [self presentViewController:mailController animated:YES completion:nil];
    }
    else
    {
        [UIAlertView showTitleInAlertView:LocalizedString(@"Вы не можете отправить email")];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)phoneTapped:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Вы действительно хотите позвонить?") message:nil delegate:self cancelButtonTitle:LocalizedString(@"Отмена") otherButtonTitles:LocalizedString(@"Позвонить"), nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSURL *url = [NSURL URLWithString:@"tel://+380487022224"];
        
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
