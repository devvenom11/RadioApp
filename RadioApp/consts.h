//
//  consts.h
//  RadioApp
//
//  Created by Pavel Gubin on 04.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "AppDelegate.h"
#import "UIView+Addionals.h"
#import "UIViewController+Additionals.h"
#import "UIAlertView+Additionals.h"
#import "SVProgressHUD.h"
#import "NetworkManager.h"
#import "UIImageView+WebCache.h"
#import "DataManager.h"
#import "AudioManager.h"
#import "NSString+TextSize.h"
#import "PodcastManager.h"


#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define SHARED_DELEGATE [AppDelegate sharedDelegate]

#define colorWithRGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

#define is_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.width == 414.0f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define is_IPHONE_6 ([[UIScreen mainScreen] bounds].size.width == 375.0f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define is_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480.0f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)


#define blueColor colorWithRGB(102, 183, 222)

#define kHelveticaNeue(fontSize) [UIFont fontWithName:@"HelveticaNeue" size:fontSize]

#define LocalizedString(string) [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[DataManager getCurrentLanguageIdentifier] ofType:@"lproj"]] localizedStringForKey:string value:@"" table:nil]

static NSString *const translateLanguages = @"ua=Украïнська,en=English,ru=Русский";

static NSString *const languageUAIdentifier = @"ua";
static NSString *const languageRusIdentifier = @"ru";
static NSString *const languageEnIdentifier = @"en";

#define kNotifDidUpateLanguage @"kNotifDidUpateLanguage"
