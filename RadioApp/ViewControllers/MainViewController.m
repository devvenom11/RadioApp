//
//  ViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 04.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MainStationView.h"
#import "InfoViewController.h"
#import <MediaPlayer/MediaPlayer.h>


@interface MainViewController () <MainStationViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate>
{    
    __weak IBOutlet UIButton *buttonPlay;
    __weak IBOutlet UIView *viewCenter;
    __weak IBOutlet UIButton *buttonCall;
    __weak IBOutlet UIScrollView *scrollViewList;
    __weak IBOutlet UIImageView *imageViewPreview;
    __weak IBOutlet UILabel *labelSongName;
    
    __weak IBOutlet UIImageView *imageViewPlay;
    __weak IBOutlet UIButton *buttonHQ;
    __weak IBOutlet UIView *viewShadow;
    
    BOOL noNeedUpdateTitle;
}


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createLogo];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 40, 40);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, -10, 0, 0);
    
    [btn setImage:[UIImage imageNamed:@"icon_menu"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    btnAction.tintColor = colorWithRGB(138, 138, 138);
    self.navigationItem.rightBarButtonItem = btnAction;
    
    if (is_IPHONE_6)
    {
        CGRect frame = viewCenter.frame;
        frame.origin.y = 450;
        viewCenter.frame = frame;
    }
    else if (is_IPHONE_6_PLUS)
    {
        CGRect frame = viewCenter.frame;
        frame.origin.y = 500;
        viewCenter.frame = frame;
    }
    else if (is_IPHONE_4)
    {
        CGRect frame = viewCenter.frame;
        frame.origin.y = 288;
        viewCenter.frame = frame;
        
        frame = labelSongName.frame;
        frame.origin.y -= 4;
        labelSongName.frame = frame;
        
        frame = imageViewPlay.frame;
        frame.size.height -= 12;
        frame.size.width -= 12;
        frame.origin.x += 6;
        frame.origin.y += 4;
        imageViewPlay.frame = frame;
        
        frame = buttonPlay.frame;
        frame.size.width -= 12;
        frame.size.height -= 12;
        frame.origin.x += 6;
        frame.origin.y += 4;
        buttonPlay.frame = frame;
    }
    
    [self setupScrollViewItems];
    [self centerCurrentPlayItem];
    
    buttonHQ.hidden = ![self hasMultipleStationsLinks];
    
    [buttonHQ setTitleColor:blueColor forState:UIControlStateNormal];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = viewShadow.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(0.8, 1.0f);
    gradientLayer.endPoint = CGPointMake(0.1f, 1.0f);
    viewShadow.layer.mask = gradientLayer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioManagerDidDownloadSongImage:) name:AudioManagerDidDownloadSongImageNotif object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioManagerDidChangeSongName:) name:AudioManagerDidChangeSongNameNotif object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioManagerDidChangeObserverToStopState) name:AudioManagerDidChangeObserverToStopStateNotif object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioManagerDidChangeObserverToRunState) name:AudioManagerDidChangeObserverToRunStateNotif object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioManagerDidChangeObserverToPlayStateNotif) name:AudioManagerDidChangeObserverToPlayStateNotif object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioHardwareRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)audioHardwareRouteChanged:(NSNotification *)notification {
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
   
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {

        if ([AudioManager sharedManager].isPlaying)
        {
            [[AudioManager sharedManager].player play];
        }
        
        if ([PodcastManager sharedManager].isPlaying)
        {
            [[PodcastManager sharedManager].player play];
        }
    }
}

- (void) audioManagerDidChangeObserverToPlayStateNotif
{
    [imageViewPlay.layer removeAllAnimations];
}

- (void) appWillResignActive
{
    if (![AudioManager sharedManager].isPlaying)
    {
        [[AudioManager sharedManager].player pause];
    }
    
    if (![PodcastManager sharedManager].isPlaying)
    {
        [[PodcastManager sharedManager].player pause];
    }
}

- (void) appDidBecomActive
{
    [self setupPlayerAfterCall];

    if ([[AudioManager sharedManager].currentStationItem[@"type"] isEqualToString:@"General"])
    {
        [imageViewPreview sd_setImageWithURL:[NSURL URLWithString:[AudioManager sharedManager].imageLink] placeholderImage:[[AudioManager sharedManager] placeHolderImage]];
    }
    else
    {
        imageViewPreview.image = [[AudioManager sharedManager] placeHolderImage];
    }

    [self setupScrollViewItems];
    buttonHQ.hidden = ![self hasMultipleStationsLinks];

    if ([AudioManager sharedManager].songName.length)
    {
        NSNotification *notif = [NSNotification notificationWithName:AudioManagerDidChangeSongNameNotif object:[AudioManager sharedManager].songName];
        [self audioManagerDidChangeSongName:notif];
    }
    
    if ([AudioManager sharedManager].isPlaying)
    {
        if (![self currentAudioTime])
        {
            if (!imageViewPlay.layer.animationKeys)
            {
                [self runImagePlayAnimation];
            }
        }

        [buttonPlay setImage:[UIImage imageNamed:@"switch-off"] forState:UIControlStateNormal];
    }
    else
    {
        [self stopImagePlayAnimation];
    }
}

- (IBAction)openFb:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com/radiomorefm"]];
}

- (IBAction)showInfoScreen:(id)sender {

    [SHARED_DELEGATE.drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void) setupPlayerAfterCall
{
    if ([PodcastManager sharedManager].isPlaying)
    {
        [[PodcastManager sharedManager].player play];
        [PodcastManager sharedManager].player.rate = 1;
    }
    else
    {
        if ([AudioManager sharedManager].isPlaying)
        {
            [[AudioManager sharedManager].player play];
            [AudioManager sharedManager].player.rate = 1;
        }
        else
        {
            noNeedUpdateTitle = YES;
            
            BOOL isPlaying = [AudioManager sharedManager].isPlaying;
            
            [[AudioManager sharedManager] clearPlayer];
            [[AudioManager sharedManager] initPlayer];
            
            [AudioManager sharedManager].isPlaying = isPlaying;
            [AudioManager sharedManager].player.volume = 0;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    SHARED_DELEGATE.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    
    if ([AudioManager sharedManager].isPlaying && !imageViewPlay.layer.animationKeys)
    {
        [self runImagePlayAnimation];
    }
    else
    {
        if ([self currentAudioTime])
        {
            [imageViewPlay.layer removeAllAnimations];
        }
    }
    
    [self setupScrollViewItems];
    buttonHQ.hidden = ![self hasMultipleStationsLinks];
    
    if ([AudioManager sharedManager].isPlaying)
    {
        [buttonPlay setImage:[UIImage imageNamed:@"switch-off"] forState:UIControlStateNormal];
    }
    else
    {
        [self audioManagerDidChangeObserverToStopState];
    }

    if ([[AudioManager sharedManager].currentStationItem[@"type"] isEqualToString:@"General"])
    {
        [imageViewPreview sd_setImageWithURL:[NSURL URLWithString:[AudioManager sharedManager].imageLink] placeholderImage:[[AudioManager sharedManager] placeHolderImage]];
    }
    else
    {
        imageViewPreview.image = [[AudioManager sharedManager] placeHolderImage];
    }
    
    if ([AudioManager sharedManager].songName.length)
    {
        NSNotification *notif = [NSNotification notificationWithName:AudioManagerDidChangeSongNameNotif object:[AudioManager sharedManager].songName];
        [self audioManagerDidChangeSongName:notif];
    }
}

#pragma mark - AudioManager delegate


- (void)audioManagerDidDownloadSongImage:(NSNotification *)notif
{
    UIImage *image = notif.object;

    if ([[AudioManager sharedManager].currentStationItem[@"type"] isEqualToString:@"General"])
    {
        imageViewPreview.image = image;
    }
    else
    {
        imageViewPreview.image = [[AudioManager sharedManager] placeHolderImage];
    }
}

- (void)audioManagerDidChangeSongName:(NSNotification *)notif
{
    NSString *name = notif.object;
    NSArray *titles = [name componentsSeparatedByString:@" - "];

    if (titles.count > 1)
    {
        NSString *title = [NSString stringWithFormat:@"%@\n%@",titles.firstObject, titles.lastObject];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:title];
        [attr addAttribute:NSFontAttributeName value:kHelveticaNeue(labelSongName.font.pointSize - 1) range:[title rangeOfString:titles.lastObject]];
        labelSongName.attributedText = attr;
    }
    else
    {
        labelSongName.text = name;
    }
}

- (void)audioManagerDidChangeObserverToStopState
{
    [self stopImagePlayAnimation];
}

- (void)audioManagerDidChangeObserverToRunState
{
    if (noNeedUpdateTitle) {
        noNeedUpdateTitle = NO;
        return;
    }
    
    labelSongName.text = nil;
    [AudioManager sharedManager].songName = nil;

    if ([AudioManager sharedManager].isPlaying)
    {
        [buttonPlay setImage:[UIImage imageNamed:@"switch-off"] forState:UIControlStateNormal];
        
        if (!imageViewPlay.layer.animationKeys.count)
        {
            [self runImagePlayAnimation];
        }
    }
}

#pragma mark - Other

- (void) scrollViewDidScroll:(UIScrollView *) scrollView
{
    if (scrollView == scrollViewList)
    {
        if (scrollView.contentOffset.x + [UIScreen mainScreen].bounds.size.width >= scrollView.contentSize.width - 48)
        {
            if (viewShadow.alpha == 1)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    viewShadow.alpha = 0;
                }];
            }
        }
        else
        {
            if (!viewShadow.alpha)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    viewShadow.alpha = 1;
                }];
            }
        }
    }
}

- (void) stopImagePlayAnimation
{
    [imageViewPlay.layer removeAllAnimations];
    [buttonPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (float) currentAudioTime
{
    return CMTimeGetSeconds([[AudioManager sharedManager].player currentTime]);
}

- (void)runImagePlayAnimation
{
    if (![self currentAudioTime])
    {
        if (!imageViewPlay.layer.animationKeys.count)
        {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [imageViewPlay setTransform:CGAffineTransformRotate(imageViewPlay.transform, M_PI_2)];
            }completion:^(BOOL finished){
                if (finished) {
                    [self runImagePlayAnimation];
                }
            }];
        }
    }
}

- (IBAction)changeHQ:(id)sender {
    
    [AudioManager sharedManager].isPlay256 = ![AudioManager sharedManager].isPlay256;
    
    if ([AudioManager sharedManager].isPlay256)
    {
        [buttonHQ setTitleColor:blueColor forState:UIControlStateNormal];
    }
    else
    {
        [buttonHQ setTitleColor:colorWithRGB(188, 188, 188) forState:UIControlStateNormal];
    }
    
    if ([AudioManager sharedManager].isPlaying)
    {
        [[AudioManager sharedManager] clearPlayer];
        [[AudioManager sharedManager] initPlayer];
    }
}

- (void) setupScrollViewItems
{
    for (UIView *view in scrollViewList.subviews)
    {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < SHARED_DELEGATE.allStations.count; i++)
    {
        NSDictionary *item = SHARED_DELEGATE.allStations[i];
        
        MainStationView *view = [MainStationView loadView];
        [view setupWithItem:item];
        view.delegate = self;
        
        if ([[AudioManager sharedManager].currentStationItem isEqualToDictionary:item])
        {
            view.imageViewActive.hidden = NO;
            view.backgroundColor = colorWithRGB(203, 203, 203);
        }
        
        CGRect frame = view.frame;
        frame.origin.x = i * view.frame.size.width;
        view.frame = frame;
        
        [scrollViewList addSubview:view];
    }
    
    scrollViewList.contentSize = CGSizeMake(SHARED_DELEGATE.allStations.count * [self stationViewWidth], scrollViewList.frame.size.height);
}

- (int) stationViewWidth
{
    return 96;
}

#pragma mark - MainStationViewDelegate

- (void) stationDidSelectWithItem:(NSDictionary *) item
{
    if (![SHARED_DELEGATE.visibleStations containsObject:item])
    {
        return;
    }
    
    [DataManager saveLastRadioStationItem:item];
    [AudioManager sharedManager].currentStationItem = item;
    [self setupScrollViewItems];
    [self play:nil];
    buttonHQ.hidden = ![self hasMultipleStationsLinks];
    
    InfoViewController *infoViewController = (InfoViewController *) SHARED_DELEGATE.drawerController.rightDrawerViewController;
    infoViewController.itemInfo = item;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifDidUpateLanguage object:nil];
}

- (BOOL) hasMultipleStationsLinks
{
    return [[AudioManager sharedManager].currentStationItem[@"link256"] length] && [[AudioManager sharedManager].currentStationItem[@"link128"] length];
}

#pragma mark - Other

- (IBAction)play:(id)sender {
    
    AVPlayerItem *item = [AudioManager sharedManager].player.currentItem;
    AVURLAsset *asset = (AVURLAsset *)item.asset;
    
    if (asset)
    {
        if ([asset.URL.relativeString isEqualToString:[[AudioManager sharedManager] audioLinkPath]])
        {
            if ([AudioManager sharedManager].isPlaying)
            {
                [AudioManager sharedManager].player.volume = 0;
                [AudioManager sharedManager].isPlaying = NO;
                [self stopImagePlayAnimation];
            }
            else
            {
                if (![AudioManager sharedManager].player)
                {
                    [[AudioManager sharedManager] initPlayer];
                }
                
                [AudioManager sharedManager].isPlaying = YES;
                [AudioManager sharedManager].player.volume = 1;
                
                [buttonPlay setImage:[UIImage imageNamed:@"switch-off"] forState:UIControlStateNormal];
                [self runImagePlayAnimation];
            }
        }
        else
        {
            [[AudioManager sharedManager] clearPlayer];
            [[AudioManager sharedManager] initPlayer];
            imageViewPreview.image = [[AudioManager sharedManager] placeHolderImage];
        }
    }
    else
    {
        [[AudioManager sharedManager] clearPlayer];
        [[AudioManager sharedManager] initPlayer];
        [buttonPlay setImage:[UIImage imageNamed:@"switch-off"] forState:UIControlStateNormal];
        [self runImagePlayAnimation];
    }
    
    [self scrollToPlayingItem];

}

- (void) centerCurrentPlayItem
{
    for (UIView *view in scrollViewList.subviews)
    {
        if ([view isKindOfClass:[MainStationView class]])
        {
            MainStationView *mainView = (MainStationView *) view;
            
            if ([mainView.item isEqualToDictionary:[AudioManager sharedManager].currentStationItem])
            {
                float centerX = view.frame.origin.x + view.frame.size.width / 2 - scrollViewList.frame.size.width / 2;
                
                if (centerX < 0)
                {
                    centerX = 0;
                }
                else if (centerX > scrollViewList.contentSize.width - scrollViewList.frame.size.width)
                {
                    centerX = scrollViewList.contentSize.width - scrollViewList.frame.size.width;
                }
                
                [scrollViewList setContentOffset:CGPointMake(centerX, 0) animated:YES];
            }
        }
    }
}
- (void) scrollToPlayingItem
{
    if ([AudioManager sharedManager].isPlaying)
    {
        [self centerCurrentPlayItem];
    }
}

- (IBAction)callTapped:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Вы действительно хотите позвонить в эфир?") message:nil delegate:self cancelButtonTitle:LocalizedString(@"Отмена") otherButtonTitles:LocalizedString(@"Позвонить"), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSURL *url = [NSURL URLWithString:@"tel:+380684829292"];
        
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

- (void) share
{
    NSString *title = @"Online radio MORE.FM. Be more!";
    
    NSString *textToShare = nil;
    
    if ([AudioManager sharedManager].isPlaying)
    {
        textToShare = [NSString stringWithFormat:@"%@\n%@ %@",title, LocalizedString(@"Я слушаю"),[AudioManager sharedManager].songName];
    }
    else if ([PodcastManager sharedManager].isPlaying)
    {
        NSDictionary *item = [PodcastManager sharedManager].currentItem;
        
        textToShare = [NSString stringWithFormat:@"%@\n%@ %@",title, LocalizedString(@"Я слушаю"),item[@"name"]];
    }
    else
    {
        textToShare = title;
    }
    
    NSURL *myWebsite = [NSURL URLWithString:@"http://more.fm"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypePostToFacebook,
                                   UIActivityTypePostToTwitter,
                                   UIActivityTypeMessage,
                                   UIActivityTypeMail];

    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void) openMenu
{
    if (SHARED_DELEGATE.drawerController.openSide == MMDrawerSideLeft)
    {
        [SHARED_DELEGATE.drawerController closeDrawerAnimated:YES completion:nil];
    }
    else
    {
        [SHARED_DELEGATE.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
