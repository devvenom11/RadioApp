//
//  AppDelegate.m
//  RadioApp
//
//  Created by Pavel Gubin on 04.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    AVAudioSession *aSession = [AVAudioSession sharedInstance];

    [aSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [aSession setMode:AVAudioSessionModeDefault error:nil];
    [aSession setActive: YES error: nil];
    
    NSArray *languages = [DataManager getLanguageAvalibleIdentifiers];
    
    if (![languages containsObject:[DataManager getCurrentLanguageIdentifier]])
    {
        [DataManager setSystemLanguage:languageRusIdentifier];
    }
    
    [self initCommanderTrack];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:aSession];
    return YES;
}


- (void)handleAudioSessionInterruption:(NSNotification*)notification {
    
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                
                if ([AudioManager sharedManager].isPlaying)
                {
                    [[AudioManager sharedManager].player play];
                    [AudioManager sharedManager].player.rate = 1;
                }
                else if ([PodcastManager sharedManager].isPlaying)
                {
                    [[PodcastManager sharedManager].player play];
                    [PodcastManager sharedManager].player.rate = 1;
                }
            }
        } break;
        default:
            break;
    }
}

- (void) initCommanderTrack
{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        if ([AudioManager sharedManager].isLastActive)
        {
            [[AudioManager sharedManager] clearPlayer];
            [[AudioManager sharedManager] initPlayer];
        }
        else if ([PodcastManager sharedManager].isLastActive)
        {
            if ([PodcastManager sharedManager].player)
            {
                [[PodcastManager sharedManager].player play];
                [PodcastManager sharedManager].isPlaying = YES;
            }
            else
            {
                [[PodcastManager sharedManager] initPlayer];
            }
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        if ([AudioManager sharedManager].isLastActive)
        {
            [[AudioManager sharedManager] clearPlayer];
        }
        else if ([PodcastManager sharedManager].isLastActive)
        {
            [[PodcastManager sharedManager].player pause];
            [PodcastManager sharedManager].isPlaying = NO;
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
     
        if ([AudioManager sharedManager].isLastActive)
        {
            [[AudioManager sharedManager] clearPlayer];
        }
        else if ([PodcastManager sharedManager].isLastActive)
        {
            [[PodcastManager sharedManager].player pause];
            [PodcastManager sharedManager].isPlaying = NO;
        }

        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        if ([AudioManager sharedManager].isLastActive)
        {
            if (self.visibleStations.count > 1)
            {
                for (NSInteger i = 0; i < self.visibleStations.count; i ++)
                {
                    NSDictionary *item = self.visibleStations[i];
                    
                    if ([item isEqualToDictionary:[AudioManager sharedManager].currentStationItem])
                    {
                        if (i + 1 <= self.visibleStations.count - 1)
                        {
                            [AudioManager sharedManager].currentStationItem = self.visibleStations[i + 1];
                        }
                        else
                        {
                            [AudioManager sharedManager].currentStationItem = self.visibleStations[0];
                        }
                        
                        break;
                    }
                }
                
                [[AudioManager sharedManager] clearPlayer];
                [[AudioManager sharedManager] initPlayer];
            }
        }
        else if ([PodcastManager sharedManager].isLastActive)
        {
            if ([DataManager sharedData].podcasts.count > 1)
            {
                for (NSInteger i = 0; i < [DataManager sharedData].podcasts.count; i ++)
                {
                    NSDictionary *item = [DataManager sharedData].podcasts[i];
                    
                    if ([item isEqualToDictionary:[PodcastManager sharedManager].currentItem])
                    {
                        if (i + 1 <= [DataManager sharedData].podcasts.count - 1)
                        {
                            [PodcastManager sharedManager].currentItem = [DataManager sharedData].podcasts[i + 1];
                        }
                        else
                        {
                            [PodcastManager sharedManager].currentItem = [DataManager sharedData].podcasts[0];
                        }
                        
                        break;
                    }
                }
                
                [[PodcastManager sharedManager] clearPlayer];
                [[PodcastManager sharedManager] initPlayer];
            }
        }

        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        if ([AudioManager sharedManager].isLastActive)
        {
            if (self.visibleStations.count > 1)
            {
                for (NSInteger i = self.visibleStations.count - 1; i >= 0; i --)
                {
                    NSDictionary *item = self.visibleStations[i];
                    
                    if ([item isEqualToDictionary:[AudioManager sharedManager].currentStationItem])
                    {
                        if (i - 1 >= 0)
                        {
                            [AudioManager sharedManager].currentStationItem = self.visibleStations[i - 1];
                        }
                        else
                        {
                            [AudioManager sharedManager].currentStationItem = self.visibleStations[self.visibleStations.count - 1];
                        }
                        
                        break;
                    }
                }
                
                [[AudioManager sharedManager] clearPlayer];
                [[AudioManager sharedManager] initPlayer];
            }
        }
        else if ([PodcastManager sharedManager].isLastActive)
        {
            if ([DataManager sharedData].podcasts.count > 1)
            {
                for (NSInteger i = [DataManager sharedData].podcasts.count - 1; i >= 0; i --)
                {
                    NSDictionary *item = [DataManager sharedData].podcasts[i];
                    
                    if ([item isEqualToDictionary:[PodcastManager sharedManager].currentItem])
                    {
                        if (i - 1 >= 0)
                        {
                            [PodcastManager sharedManager].currentItem = [DataManager sharedData].podcasts[i - 1];
                        }
                        else
                        {
                            [PodcastManager sharedManager].currentItem = [DataManager sharedData].podcasts[[DataManager sharedData].podcasts.count - 1];
                        }
                        
                        break;
                    }
                }
                
                [[PodcastManager sharedManager] clearPlayer];
                [[PodcastManager sharedManager] initPlayer];
            }
        }
      
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

+ (AppDelegate *) sharedDelegate
{
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = NO;
    commandCenter.stopCommand.enabled = NO;
    commandCenter.nextTrackCommand.enabled = NO;
    commandCenter.previousTrackCommand.enabled = NO;
}

@end
