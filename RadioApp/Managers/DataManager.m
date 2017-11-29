//
//  DataManager.m
//  RadioApp
//
//  Created by Pavel Gubin on 07.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager


+ (DataManager *) sharedData
{
    static DataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    
    return manager;
}


#pragma mark - Translate

+ (NSArray *) languageComponents
{
    NSString *translate = [translateLanguages stringByReplacingOccurrencesOfString:@" " withString:@""];
    return  [translate componentsSeparatedByString:@","];
}

+ (NSArray *) getLanguageAvalibleIdentifiers
{
    NSArray *components = [self languageComponents];
    NSMutableArray *identifiers = [NSMutableArray array];
    
    for (NSString *string in components)
    {
        NSString *identifier = [[string componentsSeparatedByString:@"="] firstObject];
        [identifiers addObject:identifier];
    }
    
    return identifiers;
}

+ (NSArray *) getLanguages
{
    return [self languageComponents];
}

+ (NSString *) getCurrentLanguageIdentifier
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
}

+ (NSString *) getCurrentLanguage
{
    NSArray *components = [self languageComponents];
    
    NSString * languageIdentifier = [self getCurrentLanguageIdentifier];
    
    for (NSString *string in components)
    {
        NSArray *langComponents = [string componentsSeparatedByString:@"="];
        NSString *identifier = langComponents.firstObject;
        
        if ([identifier isEqualToString:languageIdentifier])
        {
            return langComponents.lastObject;
        }
    }
    
    return nil;
}

+ (void) setSystemLanguage:(NSString *) lang
{
    [[NSUserDefaults standardUserDefaults] setObject:@[lang] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) saveLastRadioStationItem:(NSDictionary *) radioStation
{
    [[NSUserDefaults standardUserDefaults] setObject:radioStation forKey:@"lastRadioStation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *) visibleLastRadioStationItem
{
    NSDictionary *lastStation = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRadioStation"];
   
    if (lastStation)
    {
        for (NSDictionary *item in SHARED_DELEGATE.visibleStations)
        {
            if ([item isEqualToDictionary:lastStation])
            {
                return item;
            }
        }
    }

    return SHARED_DELEGATE.visibleStations.firstObject;;
}

@end
