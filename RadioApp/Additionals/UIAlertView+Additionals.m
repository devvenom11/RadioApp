//
//  UIAlertView+Additionals.m
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "UIAlertView+Additionals.h"

@implementation UIAlertView (Additionals)

+ (void) showTitleInAlertView:(NSString *) title
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [view show];
}

@end
