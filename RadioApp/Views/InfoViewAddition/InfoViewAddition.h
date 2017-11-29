//
//  InfoViewAddition.h
//  RadioApp
//
//  Created by Pavel Gubin on 08.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewAddition : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (weak, nonatomic) IBOutlet UIButton *buttonCall;
@end
