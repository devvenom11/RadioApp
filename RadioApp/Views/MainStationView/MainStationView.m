//
//  MainStationView.m
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "MainStationView.h"

@implementation MainStationView

- (void)setupWithItem:(NSDictionary *)item
{
    self.item = item;
    
    if ([item[@"type"] isEqualToString:@"General"])
    {
        imageViewFm.hidden = NO;
        labelTitle.hidden = YES;
    }

    labelTitle.text = item[@"name"];
    
    NSArray *colors = [item[@"color"] componentsSeparatedByString:@","];
    
    if (colors.count >= 3)
    {
        float r = [colors[0] floatValue];
        float g = [colors[1] floatValue];
        float b = [colors[2] floatValue];
        
        labelTitle.textColor = colorWithRGB(r, g, b);
        viewColor.backgroundColor = colorWithRGB(r, g, b);
    }
    
    BOOL isActive = [item[@"isActive"] boolValue];
    
    if (isActive)
    {
        labelComming.hidden = YES;
    }
    else
    {
        labelComming.hidden = NO;
        viewColor.backgroundColor = colorWithRGB(181, 181, 181);
    }
}

- (IBAction)stationDidSelect:(id)sender {
    
    [self.delegate stationDidSelectWithItem:self.item];
}



@end
