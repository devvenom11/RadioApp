//
//  ContactsViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "ContactsViewController.h"
#import <MessageUI/MessageUI.h>
#import "InfoViewAddition.h"


@interface ContactsViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelFindSocial;
    __weak IBOutlet UILabel *labelUserName;
    __weak IBOutlet UILabel *labelAddress;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLogo];
    [self createBackButtonWithOpenMenu];

    labelTitle.text = LocalizedString(@"Контакты");
    labelFindSocial.text = LocalizedString(@"Ищите нас в соцсетях:");
    
    labelUserName.text = LocalizedString(@"Елена Борисенко");
    
    labelAddress.text = LocalizedString(@"contact_address");
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 568);
    
}

- (IBAction)call:(id)sender {
    
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

- (IBAction)sendEmail:(id)sender {

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

- (IBAction)openFb:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/RadioMoreFM/"]];
}

- (IBAction)openVk:(id)sender {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://vk.com/radiomorefm"]];
}

- (IBAction)openTwit:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/radiomorefm"]];
}

- (IBAction)openInst:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.instagram.com/radiomorefm/"]];
}

- (IBAction)openTunein:(id)sender {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tunein.com/radio/Radio-MOREFM-s267511/"]];
}

- (IBAction)openMix:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.mixcloud.com/RADIOMOREFM/"]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
