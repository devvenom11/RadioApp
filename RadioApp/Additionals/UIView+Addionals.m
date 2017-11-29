//
//  UIView+Addionals.m
//  RadioApp
//
//  Created by Pavel Gubin on 04.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "UIView+Addionals.h"

@implementation UIView (Addionals)

+ (instancetype) loadView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

@end
