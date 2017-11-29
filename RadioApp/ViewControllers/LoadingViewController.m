//
//  LoadingViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "LoadingViewController.h"
#import "InfoViewController.h"
#import "MainViewController.h"


@interface LoadingViewController ()
{

}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [NetworkManager getRadioStationsWithComplete:^(NSArray *stations, NSString *errorMessage) {
        
        if (errorMessage)
        {
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            [UIAlertView showTitleInAlertView:errorMessage];
        }
        else
        {
            SHARED_DELEGATE.allStations = stations;
            
            NSMutableArray *array = [NSMutableArray array];
            
            for (NSDictionary *item in stations)
            {
                BOOL isActive = [item[@"isActive"] boolValue];
                
                if (isActive)
                {
                    [array addObject:item];
                }
            }
            
            SHARED_DELEGATE.visibleStations = array;

            [AudioManager sharedManager].currentStationItem = [DataManager visibleLastRadioStationItem];

            [[AudioManager sharedManager] initPlayer];
            [AudioManager sharedManager].player.volume = 0;
            [AudioManager sharedManager].isPlaying = NO;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioManagerDidDownloadSongImage) name:AudioManagerDidDownloadSongImageNotif object:nil];
        }
    }];
}

- (void) audioManagerDidDownloadSongImage
{
    UIViewController *menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuNav"];
    
    UINavigationController *mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNav"];
    
    InfoViewController *infoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    
    infoViewController.itemInfo = [DataManager visibleLastRadioStationItem];
    
    infoViewController.needCreateLogo = YES;
    
    SHARED_DELEGATE.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainViewController leftDrawerViewController:menuViewController rightDrawerViewController:infoViewController];

    [SHARED_DELEGATE.drawerController setMaximumLeftDrawerWidth:272];
    [SHARED_DELEGATE.drawerController setMaximumRightDrawerWidth:[UIScreen mainScreen].bounds.size.width];
    
    SHARED_DELEGATE.drawerController.showsShadow = NO;
    [SHARED_DELEGATE.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    SHARED_DELEGATE.drawerController.shouldStretchDrawer = NO;
    SHARED_DELEGATE.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    
    SHARED_DELEGATE.window.rootViewController = SHARED_DELEGATE.drawerController;
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
