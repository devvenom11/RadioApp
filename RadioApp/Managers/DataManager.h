//
//  DataManager.h
//  RadioApp
//
//  Created by Pavel Gubin on 07.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSArray *podcasts;

+ (DataManager *) sharedData;

#pragma mark - Translate

+ (NSArray *) getLanguageAvalibleIdentifiers;
+ (NSArray *) getLanguages;
+ (NSString *) getCurrentLanguage;
+ (void) setSystemLanguage:(NSString *) lang;
+ (NSString *) getCurrentLanguageIdentifier;

+ (void) saveLastRadioStationItem:(NSDictionary *) radioStation;
+ (NSDictionary *) visibleLastRadioStationItem;

@end
