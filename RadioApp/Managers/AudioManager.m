//
//  AudioManager.m
//  RadioApp
//
//  Created by Pavel Gubin on 08.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "AudioManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SDWebImageManager.h"

@implementation AudioManager

+ (AudioManager *) sharedManager
{
    static AudioManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        manager.isPlay256 = YES;
        manager.downloadingLinks = [[NSMutableArray alloc] init];
    });
    
    return manager;
}

- (void) clearPlayer
{
    if (self.player)
    {
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.player.currentItem removeObserver:self forKeyPath:@"timedMetadata"];
        
        [self.player pause];
        self.player = nil;
    }
    
    self.isPlaying = NO;
}


- (UIImage *)placeHolderImage
{
    NSString *link = [self audioLinkPath];
    
    NSString *logoKey = is_IPHONE_6_PLUS? @"logoiPhone6Plus" : @"logo";
    NSString *imagePath = self.currentStationItem[logoKey];
    
    NSString *defaultLogoName = nil;
    
    if ([imagePath.lastPathComponent rangeOfString:@".png"].location != NSNotFound)
    {
        defaultLogoName = [imagePath.lastPathComponent substringToIndex:[imagePath.lastPathComponent rangeOfString:@".png"].location].lowercaseString;
    }
    else if ([imagePath.lastPathComponent rangeOfString:@".jpg"].location != NSNotFound)
    {
        defaultLogoName = [imagePath.lastPathComponent substringToIndex:[imagePath.lastPathComponent rangeOfString:@".jpg"].location].lowercaseString;
    }
    else if ([imagePath.lastPathComponent rangeOfString:@".jpeg"].location != NSNotFound)
    {
        defaultLogoName = [imagePath.lastPathComponent substringToIndex:[imagePath.lastPathComponent rangeOfString:@".jpeg"].location].lowercaseString;
    }

    
    if ([link.lastPathComponent isEqualToString:@"more256"] ||
        [link.lastPathComponent isEqualToString:@"more128"])
    {
        if (![defaultLogoName isEqualToString:@"nocover"])
        {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imagePath];
            
            if (image)
            {
                return image;
            }
            else
            {
                [self addImageLinkToDownload:imagePath];
            }
        }
        // MORE.FM station
        return [UIImage imageNamed:@"NoCover"];
    }
    else if ([link.lastPathComponent isEqualToString:@"jazz"])
    {
        if (![defaultLogoName isEqualToString:@"jazzcover"])
        {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imagePath];
            
            if (image)
            {
                return image;
            }
            else
            {
                [self addImageLinkToDownload:imagePath];
            }
        }
        
        // JAZZ station
        return [UIImage imageNamed:@"jazzcover"];
    }
    else if ([link.lastPathComponent isEqualToString:@"90"])
    {
        if (![defaultLogoName isEqualToString:@"90scover"])
        {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imagePath];
            
            if (image)
            {
                return image;
            }
            else
            {
                [self addImageLinkToDownload:imagePath];
            }
        }
        
        // 90's stations
        return [UIImage imageNamed:@"90scover"];
    }
    
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imagePath];
    
    if (!image)
    {
        image = [self getGeneralImage];
        [self addImageLinkToDownload:imagePath];
    }
    
    return image;
}

- (UIImage *) getGeneralImage
{
    NSString *imageLink = nil;
    
    for (NSDictionary *item in SHARED_DELEGATE.visibleStations)
    {
        if ([item[@"type"] isEqualToString:@"General"])
        {
            NSString *logoKey = is_IPHONE_6_PLUS? @"logoiPhone6Plus" : @"logo";
            imageLink = item[logoKey];
            break;
        }
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageLink];

    if (image)
    {
        return image;
    }
    
    return [UIImage imageNamed:@"NoCover"];
}

- (void) addImageLinkToDownload:(NSString *) imagePath
{
    if (![self.downloadingLinks containsObject:imagePath] && imagePath)
    {
        [self.downloadingLinks addObject:imagePath];
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imagePath] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            [self.downloadingLinks removeObject:imagePath];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [self.downloadingLinks removeObject:imagePath];
        }];
    }
}
- (NSString *) audioLinkPath
{
    return self.isPlay256? self.currentStationItem[@"link256"] : self.currentStationItem[@"link128"];
}

- (void) initPlayer
{
    [[PodcastManager sharedManager] clearPlayer];
    [PodcastManager sharedManager].isLastActive = NO;
    
    self.isPlaying = YES;
    self.isLastActive = YES;
    
    NSString *link = [self audioLinkPath];
    
    if (!link.length)
    {
        if (self.isPlay256)
        {
            link = self.currentStationItem[@"link128"];
        }
        else
        {
            link = self.currentStationItem[@"link256"];
        }
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:link]];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player play];
}

- (NSString *) parsedName:(NSString *) stringValue
{
    NSArray *items = [stringValue componentsSeparatedByString:@".mp3"];

    NSString *name = items.lastObject;
    
    NSString *newString = [NSString stringWithFormat:@"%@",name];
    
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (!newString.length)
    {
        name = items.firstObject;
    }
    
    name = [name stringByReplacingOccurrencesOfString:@"\\\\Nas\\st" withString:@""];
    
    NSRange range = [name rangeOfString:@"\\M\\Programs\\"];
    
    if (range.location != NSNotFound)
    {
        name = [name substringFromIndex:range.location + range.length];
    }
    
    name = [name stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    if (!name.length)
    {
        name = items.firstObject;
    }
    
    const char *c = [name cStringUsingEncoding:NSISOLatin1StringEncoding];
    name = [[NSString alloc]initWithCString:c encoding:NSWindowsCP1251StringEncoding];
    
    name = [name stringByReplacingOccurrencesOfString:@"\t" withString:@""];

    return name;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *artistName = nil;
    NSString *songName = [AudioManager sharedManager].songName;
    
    if ([AudioManager sharedManager].songName.length)
    {
        songName = [AudioManager sharedManager].songName;
        
        NSArray *titles = [songName componentsSeparatedByString:@" - "];
        
        if (titles.count > 1)
        {
            artistName = [titles.firstObject  stringByAppendingString:[NSString stringWithFormat:@" - %@",[AudioManager sharedManager].currentStationItem[@"name"]]];
            songName = titles.lastObject;
        }
        else
        {
            artistName = [AudioManager sharedManager].currentStationItem[@"name"];
        }
    }
    
    if ([keyPath isEqualToString:@"status"])
    {
        if (self.player.status == AVPlayerStatusReadyToPlay)
        {
            MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[self placeHolderImage]];
            MPNowPlayingInfoCenter* mpic = [MPNowPlayingInfoCenter defaultCenter];
            
            if ([AudioManager sharedManager].songName.length)
            {
                mpic.nowPlayingInfo = @{MPMediaItemPropertyTitle:songName,
                                        MPMediaItemPropertyArtist : artistName,
                                        MPMediaItemPropertyArtwork: artWork};
            }
            else
            {
                mpic.nowPlayingInfo = @{MPMediaItemPropertyArtwork: artWork,
                                        MPMediaItemPropertyArtist : [AudioManager sharedManager].currentStationItem[@"name"]
                                        };
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidChangeObserverToRunStateNotif object:nil];
        }
        else
        {
            [self clearPlayer];
            [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidChangeObserverToStopStateNotif object:nil];
        }
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:audioManagerDidChangeObserverToRunStateNotif object:nil];
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidChangeObserverToPlayStateNotif object:nil];
    }
    else if ([keyPath isEqualToString:@"timedMetadata"])
    {
        NSArray *metadataList = [self.player.currentItem timedMetadata];
       
        if (metadataList.count)
        {
            for (AVMetadataItem *metaItem in metadataList)
            {
                if ([[metaItem commonKey] isEqualToString:@"title"])
                {
                    NSString *perebivkaKode = @"\\\\Nas\\st1\\J\\";

                    if ([metaItem.stringValue rangeOfString:perebivkaKode].location == NSNotFound)
                    {
                        NSString *name = [self parsedName:metaItem.stringValue];
                        
                        artistName = nil;
                        songName = name;
                        
                        NSArray *titles = [name componentsSeparatedByString:@" - "];
                        
                        if (titles.count > 1)
                        {
                            artistName = [titles.firstObject  stringByAppendingString:[NSString stringWithFormat:@" - %@",[AudioManager sharedManager].currentStationItem[@"name"]]];
                            songName = titles.lastObject;
                        }
                        else
                        {
                            artistName = [AudioManager sharedManager].currentStationItem[@"name"];
                        }
                        
                        [NetworkManager getLinkInfoWithSongName:name complete:^(NSString *imageLink, NSString *songName, NSString *trackName, NSString *errorMessage) {
                            
                            if (songName && trackName)
                            {
                                [AudioManager sharedManager].songName = [NSString stringWithFormat:@"%@\n%@",trackName, songName];
                            }
                            else
                            {
                                [AudioManager sharedManager].songName = songName;
                            }
                            
                            NSArray *titles = [songName componentsSeparatedByString:@" - "];
                            if (titles.count > 1) {
                                songName = titles.lastObject;
                            }
                            
                            MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[self placeHolderImage]];
                            MPNowPlayingInfoCenter* mpic = [MPNowPlayingInfoCenter defaultCenter];
                            
                            mpic.nowPlayingInfo = @{MPMediaItemPropertyTitle:songName,
                                                    MPMediaItemPropertyArtist : artistName,
                                                    MPMediaItemPropertyArtwork: artWork};
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidChangeSongNameNotif object:[AudioManager sharedManager].songName];
                            
                            if ([self.currentStationItem[@"type"] isEqualToString:@"General"])
                            {
                                if (imageLink.length && [imageLink.lowercaseString rangeOfString:@"nocover"].location == NSNotFound)
                                {
                                    imageLink = [NSString stringWithFormat:@"http://more.fm/admin/playlist_img/%@",imageLink];
                                    imageLink = [imageLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                    
                                    [AudioManager sharedManager].imageLink = imageLink;
                                    
                                    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageLink] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                        
                                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                        
                                        if (image)
                                        {
                                            if ([self.currentStationItem[@"type"] isEqualToString:@"General"])
                                            {
                                                if (self.isPlaying)
                                                {
                                                    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:image];
                                                    MPNowPlayingInfoCenter* mpic = [MPNowPlayingInfoCenter defaultCenter];
                                                    
                                                    mpic.nowPlayingInfo = @{MPMediaItemPropertyTitle:songName,
                                                                            MPMediaItemPropertyArtist : artistName,
                                                                            MPMediaItemPropertyArtwork: artWork};
                                                }
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidDownloadSongImageNotif object:image];
                                            }
                                        }
                                        else
                                        {
                                            self.imageLink = nil;
                                            [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidDownloadSongImageNotif object:[[AudioManager sharedManager] placeHolderImage]];
                                        }
                                    }];
                                }
                                else
                                {
                                    self.imageLink = nil;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidDownloadSongImageNotif object:[[AudioManager sharedManager] placeHolderImage]];
                                }
                            }
                            else
                            {
                                self.imageLink = nil;
                                [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidDownloadSongImageNotif object:[[AudioManager sharedManager] placeHolderImage]];
                            }
                            
                        }];
                    }
                    else
                    {
                        // тут перебивка есть
                        
//                        self.imageLink = nil;
                        [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidDownloadSongImageNotif object:[[AudioManager sharedManager] placeHolderImage]];
                    }
                    
                    break;
                }
            }
        }
        else
        {
            self.imageLink = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:AudioManagerDidDownloadSongImageNotif object:[[AudioManager sharedManager] placeHolderImage]];
        }
    }
}


@end
