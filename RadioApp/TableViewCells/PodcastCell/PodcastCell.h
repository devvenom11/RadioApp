//
//  PodcastCell.h
//  RadioApp
//
//  Created by Pavel Gubin on 21.11.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PodcastCell : UITableViewCell
{
    BOOL isMovingSlider;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelLeft;
@property (weak, nonatomic) IBOutlet UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UIView *viewMinProgress;
@property (weak, nonatomic) IBOutlet UIView *viewMaxProgress;
@property (weak, nonatomic) IBOutlet UIView *viewSliderCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minProgressConstraintWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxProgressConstraintWidth;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

- (void) setupProgress;

@end
