//
//  NetworkManager.m
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetworking.h"


@implementation NetworkManager

+ (id) parsedObjectFromResponse:(id) responseObject
{
    if ([responseObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *item = responseObject;
        NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
        
        NSArray *keys = item.allKeys;
        
        for (id key in keys)
        {
            id info = item[key];
            
            if ([info isKindOfClass:[NSArray class]] ||
                [info isKindOfClass:[NSDictionary class]])
            {
                [newDict setObject:[self parsedObjectFromResponse:info] forKey:key];
            }
            else if (![info isKindOfClass:[NSNull class]])
            {
                if ([info isKindOfClass:[NSString class]])
                {
                    if ([[info lowercaseString] isEqualToString:@"null"])
                    {
                        continue;
                    }
                }
                [newDict setObject:info forKey:key];
            }
        }
        
        return newDict;
    }
    else if ([responseObject isKindOfClass:[NSArray class]])
    {
        NSMutableArray *array = [NSMutableArray array];
        
        for (id info in responseObject)
        {
            [array addObject:[self parsedObjectFromResponse:info]];
        }
        
        return array;
    }
    else if ([responseObject isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    return responseObject;
}

+ (AFHTTPSessionManager *) getRequestWithPath:(NSString *) path parameters:(NSDictionary *) parameters complete:(void (^) (id response, NSString *errorMessage, NSInteger errorCode)) complete
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://more.fm/"]];
    [manager GET:path parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        id object = [self parsedObjectFromResponse:responseObject];
        complete (object, nil, 0);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        complete (nil, error.localizedDescription, error.code);
    }];
    
    return manager;
}

+ (void) getRadioStationsWithComplete:(void (^) (NSArray *stations, NSString *errorMessage)) complete
{
    [self getRequestWithPath:@"morefmconf.json" parameters:nil complete:^(id response, NSString *errorMessage, NSInteger errorCode) {
        complete (response, errorMessage);
    }];
}


+ (void) getLinkInfoWithSongName:(NSString *) songName complete:(void (^) (NSString *imageLink, NSString *songName, NSString *trackName, NSString *errorMessage)) complete
{
    NSDictionary *params = nil;
    
    if ([[AudioManager sharedManager].audioLinkPath rangeOfString:@"more256"].location != NSNotFound ||
        [[AudioManager sharedManager].audioLinkPath rangeOfString:@"more128"].location != NSNotFound)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"EEEE"];
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en"];
        dateFormatter.locale = locale;
        NSString *day = [dateFormatter stringFromDate:[NSDate date]];
        
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        dateFormatter.locale = [NSLocale currentLocale];
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        
        params = @{@"track_name" : songName,
                   @"curren_time" : time,
                   @"curren_day" : day};
    }
    else
    {
        params = @{@"track_name" : songName};
    }
   

    AFHTTPSessionManager *manager = [self getRequestWithPath:@"send-track" parameters:params complete:^(id response, NSString *errorMessage, NSInteger errorCode) {
        
        NSString *song = response[@"song"];
        NSString *name = response[@"name"];
        
        if (song && name)
        {
            complete (response[@"image"], response[@"song"], response[@"name"], errorMessage);
        }
        else
        {
            complete (response[@"image"], songName, nil, errorMessage);
        }
    }];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
}

+ (void) getPodcastsWithComplete:(void(^)(NSArray *podcasts, NSString *errorMessage)) complete
{
    [self getRequestWithPath:@"podcasts/morefmpodcast.json" parameters:nil complete:^(id response, NSString *errorMessage, NSInteger errorCode) {
        complete (response, errorMessage);
    }];
}

@end
