//
//  PodcastManager.h
//  RadioApp
//
//  Created by Pavel Gubin on 18.12.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PodcastManager : NSObject

@property (nonatomic, strong, readonly) NSString *currentPlayLink;
@property (nonatomic, strong) NSDictionary *currentItem;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isLastActive;

+ (PodcastManager *) sharedManager;

- (void) initPlayer;
- (void) clearPlayer;

@end
