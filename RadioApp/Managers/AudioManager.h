//
//  AudioManager.h
//  RadioApp
//
//  Created by Pavel Gubin on 08.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


static NSString *const AudioManagerDidChangeObserverToRunStateNotif = @"audioManagerDidChangeObserverToRunState";
static NSString *const AudioManagerDidChangeObserverToStopStateNotif = @"audioManagerDidChangeObserverToStopState";
static NSString *const AudioManagerDidChangeObserverToPlayStateNotif = @"audioManagerDidChangeObserverToPlayStateNotif";
static NSString *const AudioManagerDidChangeSongNameNotif = @"audioManagerDidChangeSongName";
static NSString *const AudioManagerDidDownloadSongImageNotif = @"audioManagerDidDownloadSongImage";

static NSString *const PodcastManagerDidChangeObserverToStopStateNotif = @"PodcastManagerDidChangeObserverToStopStateNotif";

@interface AudioManager : NSObject

@property (nonatomic, assign) BOOL isPlay256;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isLastActive;

@property (nonatomic, strong) NSDictionary *currentStationItem;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) NSString *imageLink;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSMutableArray *downloadingLinks;

+ (AudioManager *) sharedManager;

- (void) clearPlayer;
- (void) initPlayer;
- (NSString *) audioLinkPath;

- (UIImage *) placeHolderImage;

@end
