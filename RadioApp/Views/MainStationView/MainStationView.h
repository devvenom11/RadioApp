//
//  MainStationView.h
//  RadioApp
//
//  Created by Pavel Gubin on 05.07.16.
//  Copyright © 2016 Pavel Gubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainStationViewDelegate <NSObject>

- (void) stationDidSelectWithItem:(NSDictionary *) item;

@end

@interface MainStationView : UIView
{
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UIImageView *imageViewFm;
    
    __weak IBOutlet UIView *viewColor;
    __weak IBOutlet UILabel *labelComming;
}

@property (nonatomic, strong) NSDictionary *item;
@property (nonatomic, weak) id <MainStationViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewActive;

- (void) setupWithItem:(NSDictionary *) item;

@end
