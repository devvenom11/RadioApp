//
//  AppDelegate.h
//  RadioApp
//
//  Created by Pavel Gubin on 04.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) MMDrawerController *drawerController;
@property (strong, nonatomic) UIWindow *window;

@property (nonnull, strong) NSArray *allStations;
@property (nonnull, strong) NSArray *visibleStations;


+ (AppDelegate *) sharedDelegate;

@end

