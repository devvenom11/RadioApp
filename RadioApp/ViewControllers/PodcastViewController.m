//
//  PodcastViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 21.11.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "PodcastViewController.h"
#import "PodcastCell.h"
#import "PreloadTableViewCell.h"


@interface PodcastViewController ()
{
    BOOL isPreloading;
    
    NSDateFormatter *dateFormatter;

    NSTimer *timer;
    __weak IBOutlet UILabel *labelTitle;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PodcastViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createLogo];
    [self createBackButtonWithOpenMenu];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    labelTitle.text = LocalizedString(@"Подкасты");
    
    isPreloading = YES;
    [NetworkManager getPodcastsWithComplete:^(NSArray *podcasts, NSString *errorMessage) {
        
        isPreloading = NO;
        
        if (errorMessage)
        {
            [UIAlertView showTitleInAlertView:errorMessage];
        }
        
        if (podcasts.count)
        {
            [DataManager sharedData].podcasts = podcasts;
        }
        
        [self.tableView reloadData];
    }];

    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:PodcastManagerDidChangeObserverToStopStateNotif object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
}

- (void) backButtonMenuTapped
{
    [timer invalidate];
    timer = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
    [SHARED_DELEGATE.drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void) updateUI
{
    for (UITableViewCell *cell in self.tableView.visibleCells)
    {
        if ([cell isKindOfClass:[PodcastCell class]])
        {
            if ([PodcastManager sharedManager].isPlaying)
            {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                
                NSDictionary *item = [DataManager sharedData].podcasts[indexPath.row];
                
                if ([item isEqualToDictionary:[PodcastManager sharedManager].currentItem])
                {
                    PodcastCell *_cell = (PodcastCell *) cell;
                    [_cell setupProgress];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [PodcastManager sharedManager].currentItem = [DataManager sharedData].podcasts[indexPath.row];
        
        AVPlayerItem *playerItem = [PodcastManager sharedManager].player.currentItem;
        AVURLAsset *asset = (AVURLAsset *)playerItem.asset;
        
        if (asset)
        {
            if ([asset.URL.relativeString isEqualToString:[PodcastManager sharedManager].currentPlayLink])
            {
                if ([PodcastManager sharedManager].isPlaying)
                {
                    [[PodcastManager sharedManager].player pause];
                    [PodcastManager sharedManager].isPlaying = NO;
                }
                else
                {
                    [[PodcastManager sharedManager].player play];
                    [PodcastManager sharedManager].isPlaying = YES;
                }
//                [[PodcastManager sharedManager] clearPlayer];
            }
            else
            {
                [[PodcastManager sharedManager] clearPlayer];
                [[PodcastManager sharedManager] initPlayer];
            }
        }
        else
        {
            [[PodcastManager sharedManager] clearPlayer];
            [[PodcastManager sharedManager] initPlayer];
        }
        
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return 50;
    }
    
    return 110;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [DataManager sharedData].podcasts.count;
    }
    
    return isPreloading? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        static NSString *identifier = @"PreloadTableViewCell";
        PreloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil)
        {
            cell = [PreloadTableViewCell loadView];
        }
        
        [cell.activityIndicatorView startAnimating];
        
        return cell;
    }
    
    static NSString *identifier = @"PodcastCell";
   
    PodcastCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
   
    if (cell == nil)
    {
        cell = [PodcastCell loadView];
        cell.buttonPlay.userInteractionEnabled = NO;
    }
    
    cell.buttonPlay.tag = indexPath.row;
    
    NSDictionary *item = [DataManager sharedData].podcasts[indexPath.row];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.labelLeft.hidden = YES;
    cell.labelCurrentTime.hidden = YES;
    cell.sliderControl.hidden = YES;
    cell.viewMaxProgress.hidden = YES;
    cell.viewMinProgress.hidden = YES;
    cell.viewSliderCenter.hidden = YES;
    
    if ([item isEqualToDictionary:[PodcastManager sharedManager].currentItem])
    {
        if ([PodcastManager sharedManager].isPlaying)
        {
            cell.backgroundColor = colorWithRGB(246, 246, 246);
            
            cell.labelLeft.hidden = NO;
            cell.labelCurrentTime.hidden = NO;
            cell.sliderControl.hidden = NO;
            cell.viewMaxProgress.hidden = NO;
            cell.viewMinProgress.hidden = NO;
            cell.viewSliderCenter.hidden = NO;

            [cell.buttonPlay setImage:[UIImage imageNamed:@"podcast-switch-off"] forState:UIControlStateNormal];
            
            [cell setupProgress];

        }
        else
        {
            [cell.buttonPlay setImage:[UIImage imageNamed:@"podcast-play-station"] forState:UIControlStateNormal];
        }
   }
    else
    {
        [cell.buttonPlay setImage:[UIImage imageNamed:@"podcast-play-station"] forState:UIControlStateNormal];
    }
    
    NSString *imgLink = item[@"img"];
    imgLink = [imgLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [cell.imageViewLogo sd_setImageWithURL:[NSURL URLWithString:imgLink]];
    cell.labelTitle.text = item[@"name"];
    cell.labelTime.text = item[@"time"];
    
    
    
    return cell;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
