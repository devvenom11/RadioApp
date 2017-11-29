//
//  PodcastCell.m
//  RadioApp
//
//  Created by Pavel Gubin on 21.11.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import "PodcastCell.h"

@implementation PodcastCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.imageViewLogo.layer.borderWidth = 1;
    self.imageViewLogo.layer.borderColor = colorWithRGB(220, 220, 220).CGColor;

    self.viewSliderCenter.layer.cornerRadius = 7;
    self.viewSliderCenter.clipsToBounds = YES;
    self.viewSliderCenter.layer.borderWidth = 1;
    self.viewSliderCenter.layer.borderColor = [UIColor whiteColor].CGColor;
    self.sliderControl.maximumTrackTintColor = [UIColor clearColor];
    self.sliderControl.minimumTrackTintColor = [UIColor clearColor];
    self.sliderControl.thumbTintColor = [UIColor clearColor];


    [self.sliderControl addTarget:self action:@selector(UIControlEventValueChanged) forControlEvents:UIControlEventValueChanged];

    [self.sliderControl addTarget:self action:@selector(UIControlEventTouchDown) forControlEvents:UIControlEventTouchDown];

    [self.sliderControl addTarget:self action:@selector(UIControlEventTouchDragExit) forControlEvents:UIControlEventTouchDragExit];

    [self.sliderControl addTarget:self action:@selector(UIControlEventTouchUpInside) forControlEvents:UIControlEventTouchUpInside];

    [self.sliderControl addTarget:self action:@selector(UIControlEventTouchCancel) forControlEvents:UIControlEventTouchCancel];
}

- (void) UIControlEventValueChanged
{
    [self setupProgress];
}


- (void)UIControlEventTouchDown
{
    isMovingSlider = YES;
}

- (void)UIControlEventTouchDragExit
{
    isMovingSlider = NO;
}

- (void)UIControlEventTouchUpInside
{
    isMovingSlider = NO;
    
    if ([PodcastManager sharedManager].player.status == AVPlayerStatusReadyToPlay)
    {
        int32_t timeScale = [PodcastManager sharedManager].player.currentItem.asset.duration.timescale;
        CMTime time = CMTimeMakeWithSeconds(self.sliderControl.value, timeScale);
        [[PodcastManager sharedManager].player seekToTime:time];
    
//        [self setupProgress];
    }
}

- (void)UIControlEventTouchCancel
{
    isMovingSlider = NO;

}

- (void) setCorners:(UIRectCorner) corners view:(UIView *) view
{
    CGRect bounds = CGRectNull;
    
    if (view == self.viewMinProgress)
    {
        bounds = CGRectMake(0, 0, self.minProgressConstraintWidth.constant, view.frame.size.height);
    }
    else if (view == self.viewMaxProgress)
    {
        bounds = CGRectMake(0, 0, self.maxProgressConstraintWidth.constant, view.frame.size.height);
    }
    
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:bounds
                              byRoundingCorners:corners
                              cornerRadii:CGSizeMake(4, 4)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    self.viewContainer.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setupProgress
{
    int maxWidth = SCREEN_WIDTH - 10 - 15 - 75 - 15;
    float duration = CMTimeGetSeconds([PodcastManager sharedManager].player.currentItem.duration);

    if ([PodcastManager sharedManager].player.status == AVPlayerStatusReadyToPlay && !isnan(duration))
    {
        if (self.sliderControl.maximumValue != duration)
        {
            self.sliderControl.maximumValue = duration;
        }        
    
        if (!isMovingSlider)
        {
            self.sliderControl.value = CMTimeGetSeconds([PodcastManager sharedManager].player.currentTime);
        }
        
        float width = maxWidth * self.sliderControl.value / self.sliderControl.maximumValue;
        
        self.minProgressConstraintWidth.constant = width;
        self.maxProgressConstraintWidth.constant = maxWidth - width;
        
        [self setCorners:(UIRectCornerBottomLeft | UIRectCornerTopLeft) view:self.viewMinProgress];
        [self setCorners:(UIRectCornerBottomRight | UIRectCornerTopRight) view:self.viewMaxProgress];
    
        int durationCurrentTime = self.sliderControl.value;
        int seconds = durationCurrentTime % 60;
        int minutes = (durationCurrentTime / 60) % 60;
        int hours = durationCurrentTime / 3600;
        
        if (minutes && hours)
        {
            self.labelCurrentTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes,seconds];
        }
        else
        {
            self.labelCurrentTime.text = [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
        }
        
        durationCurrentTime = duration - self.sliderControl.value;
        seconds = durationCurrentTime % 60;
        minutes = (durationCurrentTime / 60) % 60;
        hours = durationCurrentTime / 3600;
    
        if (minutes && hours)
        {
            self.labelLeft.text = [NSString stringWithFormat:@"-%02d:%02d:%02d",hours, minutes, seconds];
        }
        else
        {
            self.labelLeft.text = [NSString stringWithFormat:@"-%02d:%02d",minutes, seconds];
        }
    }
    else
    {
        self.labelLeft.text = @"00:00";
        self.labelCurrentTime.text = @"00:00";
        
        self.sliderControl.value = 0;

        self.minProgressConstraintWidth.constant = 0;
        self.maxProgressConstraintWidth.constant = maxWidth;
    }
}


@end
