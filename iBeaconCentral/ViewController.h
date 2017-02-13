//
//  ViewController.h
//  iBeaconCentral
//
//  Created by shoichi yokobori on 2017/02/11.
//  Copyright © 2017年 shoichi yokobori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *range;
@property (weak, nonatomic) IBOutlet UILabel *major;
@property (weak, nonatomic) IBOutlet UILabel *minor;
@property (weak, nonatomic) IBOutlet UILabel *accuracy;
@property (weak, nonatomic) IBOutlet UILabel *rssi;

@property (weak, nonatomic) IBOutlet UILabel *timer;

@end

