//
//  NetworkManager.h
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (void) getRadioStationsWithComplete:(void (^) (NSArray *stations, NSString *errorMessage)) complete;
+ (void) getLinkInfoWithSongName:(NSString *) songName complete:(void (^) (NSString *imageLink, NSString *songName, NSString *trackName, NSString *errorMessage)) complete;

+ (void) getPodcastsWithComplete:(void(^)(NSArray *podcasts, NSString *errorMessage)) complete;

@end
