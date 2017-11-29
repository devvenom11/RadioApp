//
//  SettingViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 07.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "SettingViewController.h"
#import "LanguageCell.h"

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLogo];
    [self createBackButtonWithOpenMenu];
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:kNotifDidUpateLanguage object:nil];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            UIViewController *languageController = [self.storyboard instantiateViewControllerWithIdentifier:@"LanguageViewController"];
            [self.navigationController pushViewController:languageController animated:YES];
        }
    }
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
        
        cell.backgroundColor = colorWithRGB(185, 185, 185);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = LocalizedString(@"Настройки");
        cell.textLabel.font = kHelveticaNeue(22);
        
        return cell;
    }
    
    static NSString *identifier = @"LanguageCell";
    
    LanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [LanguageCell loadView];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.labelTitle.text = LocalizedString(@"Язык");
    cell.imageViewIcon.hidden = YES;
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
    
    return 1;
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
