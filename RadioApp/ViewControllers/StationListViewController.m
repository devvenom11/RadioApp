//
//  StationListViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "StationListViewController.h"
#import "StationTableViewCell.h"
#import "InfoViewController.h"
#import "MainViewController.h"

@interface StationListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation StationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLogo];
    [self createBackButtonWithOpenMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:AudioManagerDidChangeObserverToRunStateNotif object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:AudioManagerDidChangeObserverToStopStateNotif object:nil];
}

- (void) playTapped:(UIButton *) sender
{
    NSInteger index = sender.tag;

    MainViewController *mainController = self.navigationController.viewControllers[0];
    [mainController stationDidSelectWithItem:SHARED_DELEGATE.allStations[index]];
    [self.tableView reloadData];
}

- (void) infoTapped:(UIButton *) sender
{
    NSInteger index = sender.tag;
    
    InfoViewController *infoController = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    infoController.itemInfo = SHARED_DELEGATE.allStations[index];
    [self.navigationController pushViewController:infoController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainViewController *mainController = self.navigationController.viewControllers[0];
    [mainController stationDidSelectWithItem:SHARED_DELEGATE.allStations[indexPath.row]];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *identifier = @"cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 59, [UIScreen mainScreen].bounds.size.width, 1)];
            view.backgroundColor = colorWithRGB(239, 239, 239);
            [cell addSubview:view];
        }
        
        cell.backgroundColor = colorWithRGB(0, 188, 75);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = LocalizedString(@"Станции");
        cell.textLabel.font = kHelveticaNeue(22);
        
        return cell;
    }
    
    static NSString *identifier = @"StationTableViewCell";
    
    StationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [StationTableViewCell loadView];
        [cell.buttonPlay addTarget:self action:@selector(playTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonInfo addTarget:self action:@selector(infoTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.buttonPlay.tag = indexPath.row;
    cell.buttonInfo.tag = indexPath.row;
    
    NSDictionary *item = SHARED_DELEGATE.allStations[indexPath.row];
    
    cell.labelTitle.text = [item[@"name"] uppercaseString];
    
    NSArray *colors = [item[@"color"] componentsSeparatedByString:@","];
    
    if (colors.count >= 3)
    {
        float r = [colors[0] floatValue];
        float g = [colors[1] floatValue];
        float b = [colors[2] floatValue];
        
        cell.viewColor.backgroundColor = colorWithRGB(r, g, b);
    }
    
    BOOL isActive = [item[@"isActive"] boolValue];
    cell.labelComming.hidden = isActive;
    
    cell.imageViewIconCircle.hidden = !isActive;
    cell.buttonPlay.hidden = !isActive;
    cell.buttonInfo.hidden = !isActive;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    if ([AudioManager sharedManager].isPlaying)
    {
        if ([[AudioManager sharedManager].currentStationItem isEqualToDictionary:item])
        {
            [cell runAnimationCell];
            cell.backgroundColor = colorWithRGB(240, 240, 240);
        }
        else
        {
            [cell stopAnimationCell];
        }
    }
    else
    {
        [cell stopAnimationCell];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    
    return SHARED_DELEGATE.allStations.count;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
