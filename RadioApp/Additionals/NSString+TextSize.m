//
//  NSString+TextSize.m
//  UGRA
//
//  Created by Pavel Gubin on 09.11.14.
//  Copyright (c) 2014 Pavel Gubin. All rights reserved.
//

#import "NSString+TextSize.h"

@implementation NSString (TextSize)

- (float) heightWithFont:(UIFont *) font maxWidth:(float) width
{
    if (!self.length)
    {
        return 0;
    }
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName : font}];
    return ceilf([attr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height);
}

- (float) widthWithFont:(UIFont *) font
{
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName : font}];
    return ceilf([attr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width);
}

@end
