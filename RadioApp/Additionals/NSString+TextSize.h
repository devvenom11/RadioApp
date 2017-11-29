//
//  NSString+TextSize.h
//  UGRA
//
//  Created by Pavel Gubin on 09.11.14.
//  Copyright (c) 2014 Pavel Gubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TextSize)

- (float) heightWithFont:(UIFont *) font maxWidth:(float) width;
- (float) widthWithFont:(UIFont *) font;

@end
