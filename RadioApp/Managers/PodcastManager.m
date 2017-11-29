//
//  PodcastManager.m
//  RadioApp
//
//  Created by Pavel Gubin on 18.12.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "PodcastManager.h"

@implementation PodcastManager

+ (PodcastManager *) sharedManager
{
    static PodcastManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    
    return manager;
}

- (void)setCurrentItem:(NSDictionary *)currentItem
{
    _currentItem = currentItem;
    
    NSString *link = currentItem[@"mp3"];
    link = [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _currentPlayLink = link;
}

- (void) clearPlayer
{    
    if (self.player)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.player.currentItem removeObserver:self forKeyPath:@"timedMetadata"];
        
        [self.player pause];
        self.player = nil;
    }
    
    self.isPlaying = NO;
}

- (void) initPlayer
{
    [AudioManager sharedManager].isLastActive = NO;
    
    if ([AudioManager sharedManager].player)
    {
        [[AudioManager sharedManager] clearPlayer];
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidChangeObserverToStopStateNotif object:nil];
    }

    self.isPlaying = YES;
    self.isLastActive = YES;
    
    if (self.player)
    {
        [self.player pause];
        self.player = nil;
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.currentPlayLink]];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];

    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player play];
}

- (void) itemDidFinishPlaying:(NSNotification *) notification
{
    [self clearPlayer];
    [[NSNotificationCenter defaultCenter] postNotificationName:PodcastManagerDidChangeObserverToStopStateNotif object:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        if (self.player.status == AVPlayerStatusReadyToPlay)
        {
            NSString *imgLink = self.currentItem[@"img"];
            imgLink = [imgLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgLink];

            if (image)
            {
                MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:image];
                MPNowPlayingInfoCenter* mpic = [MPNowPlayingInfoCenter defaultCenter];
                mpic.nowPlayingInfo = @{MPMediaItemPropertyTitle:self.currentItem[@"name"],
                                        MPMediaItemPropertyArtwork: artWork};
            }
            else
            {

                MPNowPlayingInfoCenter* mpic = [MPNowPlayingInfoCenter defaultCenter];
                mpic.nowPlayingInfo = @{MPMediaItemPropertyTitle:self.currentItem[@"name"]};

                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imgLink] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    
                    if (image && self.isPlaying)
                    {
                        MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:image];
                        MPNowPlayingInfoCenter* mpic = [MPNowPlayingInfoCenter defaultCenter];
                        mpic.nowPlayingInfo = @{MPMediaItemPropertyTitle:self.currentItem[@"name"],
                                                MPMediaItemPropertyArtwork: artWork};
                    }
                }];
            }
        }
        else
        {
            [self clearPlayer];
            [[NSNotificationCenter defaultCenter] postNotificationName:PodcastManagerDidChangeObserverToStopStateNotif object:nil];
        }
    }

}

@end
