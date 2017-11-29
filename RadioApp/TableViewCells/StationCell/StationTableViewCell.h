//
//  StationTableViewCell.h
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewColor;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelComming;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIconCircle;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;
@property (weak, nonatomic) IBOutlet UIButton *buttonInfo;

- (void) runAnimationCell;
- (void) stopAnimationCell;

@end
