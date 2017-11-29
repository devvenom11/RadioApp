//
//  StationTableViewCell.m
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "StationTableViewCell.h"

@implementation StationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)runAnimationCell
{
    [self.buttonPlay setImage:[UIImage imageNamed:@"switch-off-gray"] forState:UIControlStateNormal];

    if (!self.imageViewIconCircle.layer.animationKeys.count)
    {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.imageViewIconCircle setTransform:CGAffineTransformRotate(self.imageViewIconCircle.transform, M_PI_2)];
        }completion:^(BOOL finished){
            if (finished) {
                [self runAnimationCell];
            }
        }];
    }
}

- (void)stopAnimationCell
{
    [self.imageViewIconCircle.layer removeAllAnimations];
    [self.buttonPlay setImage:[UIImage imageNamed:@"play-station-gray"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
