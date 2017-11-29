//
//  LanguageViewController.m
//  RadioApp
//
//  Created by Pavel Gubin on 07.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanguageCell.h"

@interface LanguageViewController ()
{
    NSIndexPath *selectedIndex;
    NSArray *languages;
}

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLogo];
    [self createBackButton];
    
    languages = [DataManager getLanguages];
    
    for (int i = 0; i < languages.count; i ++)
    {
        NSString *component = languages[i];
        NSString *languageIdentifier = [[component componentsSeparatedByString:@"="] firstObject];
        if ([languageIdentifier isEqualToString:[DataManager getCurrentLanguageIdentifier]])
        {
            selectedIndex = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath;
    id component = languages[indexPath.row];
    NSString *languageIdentifier = [[component componentsSeparatedByString:@"="] firstObject];
    [DataManager setSystemLanguage:languageIdentifier];
    
    [tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifDidUpateLanguage object:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"LanguageCell";
    
    LanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [LanguageCell loadView];
    }
    
    NSString *component = languages[indexPath.row];
    NSString *languageIdentifier = [component componentsSeparatedByString:@"="].firstObject;
    NSString *language = [[component componentsSeparatedByString:@"="] lastObject];
    
    cell.labelTitle.text = language;

    cell.backgroundColor = [UIColor whiteColor];
    
    UIColor *lightGrayColor = colorWithRGB(240, 240, 240);
    
    if ([languageIdentifier isEqualToString:languageRusIdentifier])
    {
        if ([selectedIndex isEqual:indexPath])
        {
            cell.backgroundColor = lightGrayColor;
            cell.imageViewIcon.image = [UIImage imageNamed:@"Rus-included-icon"];
        }
        else
        {
            cell.imageViewIcon.image = [UIImage imageNamed:@"Rus-off-icon"];
        }
    }
    else if ([languageIdentifier isEqualToString:languageEnIdentifier])
    {
        if ([selectedIndex isEqual:indexPath])
        {
            cell.backgroundColor = lightGrayColor;
            cell.imageViewIcon.image = [UIImage imageNamed:@"Eng-included-icon"];
        }
        else
        {
            cell.imageViewIcon.image = [UIImage imageNamed:@"Eng-off-icon"];
        }
    }
    else if ([languageIdentifier isEqualToString:languageUAIdentifier])
    {
        if ([selectedIndex isEqual:indexPath])
        {
            cell.backgroundColor = lightGrayColor;
            cell.imageViewIcon.image = [UIImage imageNamed:@"Ukr-included-icon"];
        }
        else
        {
            cell.imageViewIcon.image = [UIImage imageNamed:@"Ukr-off-icon"];

        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
