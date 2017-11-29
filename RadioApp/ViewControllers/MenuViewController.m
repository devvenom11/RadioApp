//
//  MenuViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 04.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuTableViewCell.h"


@interface MenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLogo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:kNotifDidUpateLanguage object:nil];
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        UINavigationController *nav = (UINavigationController *) SHARED_DELEGATE.drawerController.centerViewController;
        [nav popToRootViewControllerAnimated:YES];
        [SHARED_DELEGATE.drawerController closeDrawerAnimated:YES completion:nil];
    }
    else if (indexPath.row == 1)
    {
        [self pushViewControllerWithIdentifier:@"StationListViewController"];
    }
    else if (indexPath.row == 2)
    {
        [self pushViewControllerWithIdentifier:@"CorporativeViewController"];
    }
    else if (indexPath.row == 3)
    {
        [self pushViewControllerWithIdentifier:@"PodcastViewController"];
    }
    else if (indexPath.row == 4)
    {
        [self pushViewControllerWithIdentifier:@"ContactsViewController"];
    }
    else if (indexPath.row == 5)
    {
        [self pushViewControllerWithIdentifier:@"SettingViewController"];
    }
}

- (void) pushViewControllerWithIdentifier:(NSString *) identifier
{
    UINavigationController *nav = (UINavigationController *) SHARED_DELEGATE.drawerController.centerViewController;
    
    if (nav.viewControllers.count > 1)
    {
        UIViewController *viewController = nav.viewControllers.lastObject;
        
        if (![viewController isKindOfClass:NSClassFromString(identifier)])
        {
            [nav popToRootViewControllerAnimated:NO];
            UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            [nav pushViewController:viewController animated:NO];
        }
        
        [SHARED_DELEGATE.drawerController closeDrawerAnimated:YES completion:nil];
    }
    else
    {
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        [nav pushViewController:viewController animated:YES];
        [SHARED_DELEGATE.drawerController closeDrawerAnimated:YES completion:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MenuTableViewCell";
    
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [MenuTableViewCell loadView];
    }
    
    
    if (indexPath.row == 0)
    {
        cell.labelTitle.text = LocalizedString(@"Слушать");
        cell.backgroundColor = colorWithRGB(233, 164, 49);
        cell.imageViewIcon.image = [UIImage imageNamed:@"listen-icon"];
    }
    else if (indexPath.row == 1)
    {
        cell.labelTitle.text = LocalizedString(@"Станции");
        cell.backgroundColor = colorWithRGB(0, 188, 75);
        cell.imageViewIcon.image = [UIImage imageNamed:@"station-icon"];
    }
    else if (indexPath.row == 2)
    {
        cell.labelTitle.text = LocalizedString(@"Корпоративное радио");
        cell.backgroundColor = colorWithRGB(151, 118, 178);
        cell.imageViewIcon.image = [UIImage imageNamed:@"corporat-icon"];
    }
    else if (indexPath.row == 3)
    {
        cell.labelTitle.text = LocalizedString(@"Подкасты");
        cell.backgroundColor = colorWithRGB(221, 111, 97);
        cell.imageViewIcon.image = [UIImage imageNamed:@"podkast-icon"];
    }
    else if (indexPath.row == 4)
    {
        cell.labelTitle.text = LocalizedString(@"Контакты");
        cell.backgroundColor = colorWithRGB(1, 184, 224);
        cell.imageViewIcon.image = [UIImage imageNamed:@"contacts-icon"];
    }
    else if (indexPath.row == 5)
    {
        cell.labelTitle.text = LocalizedString(@"Настройки");
        cell.backgroundColor = colorWithRGB(185, 185, 185);
        cell.imageViewIcon.image = [UIImage imageNamed:@"settings-icon"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
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
