//
//  ViewController.m
//  iBeaconCentral
//
//  Created by shoichi yokobori on 2017/02/11.
//  Copyright © 2017年 shoichi yokobori. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@end


@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
    // CLLocationManagerの生成とデリゲートの設定
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    // 生成したUUIDからNSUUIDを作成
//    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"BDB97A05-86E7-47BE-88E3-4455F2B285E4"];   // ランダム生成
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"5A506336-4948-4AFD-A2CD-29F549B25546"];   // app調べ
//    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"];   // 自分で調べた

    // CLBeaconRegionを作成
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"shiiiiiiiii1"];

    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
      [self.locationManager requestAlwaysAuthorization];
    } else {
      // Beaconによる領域観測を開始
      [self.locationManager startMonitoringForRegion: self.beaconRegion];
    }

  } else {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"確認" message:@"お使いの端末ではiBeaconを利用できません。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//    [alert show];
    NSLog(@"cannot use");
  }

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}



#pragma mark - CLLocationManagerDelegate methods
// 領域計測が開始した場合
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  [self.locationManager requestStateForRegion:self.beaconRegion];
}

// 領域内にいるかいないかの判断
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
  switch (state) {
    case CLRegionStateInside:   // リージョン内にいる
      if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
      }
      break;
    case CLRegionStateOutside:
    case CLRegionStateUnknown:
    default:
      break;
  }
}

// 領域に侵入した場合
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  // ローカル通知
  //  [self sendLocalNotificationForMessage:@"Enter Region"];
  NSLog(@"Enter Region");

  if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
    [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
  }
}

// 領域から退出した場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  // ローカル通知
//  [self sendLocalNotificationForMessage:@"Exit Region"];
  NSLog(@"Exit Region");
  
  // Beaconの距離測定を終了する
  if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
    [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
  }
}

/* 距離イベントのハンドリング */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
  if (beacons.count > 0) {
    // 最も距離の近いBeaconについて処理する
    CLBeacon *nearestBeacon = beacons.firstObject;
    
    NSString *rangeMessage;
    
    // Beacon の距離でメッセージを変える
    switch (nearestBeacon.proximity) {
      case CLProximityImmediate:
        rangeMessage = @"Range:Immediate";
        break;
      case CLProximityNear:
        rangeMessage = @"Range:Near";
        break;
      case CLProximityFar:
        rangeMessage = @"Range:Far";
        break;
      default:
        rangeMessage = @"Range:Unknown";
        break;
    }
    
    // ローカル通知
    NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%ld", nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, (long)nearestBeacon.rssi];
//    [self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];
    NSLog(@"%@ %@", rangeMessage, message);   // ここで値の更新がされる
    _range.text = rangeMessage;
    _major.text = [NSString stringWithFormat:@"major:%@", nearestBeacon.major];
    _minor.text = [NSString stringWithFormat:@"minor:%@", nearestBeacon.minor];
    _accuracy.text = [NSString stringWithFormat:@"accuracy:%f", nearestBeacon.accuracy];
    _rssi.text = [NSString stringWithFormat:@"rssi:%ld", nearestBeacon.rssi];
  }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
//  [self sendLocalNotificationForMessage:@"Exit Region"];
  NSLog(@"Exit Region");
}

// 位置情報の許可設定
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  if (status == kCLAuthorizationStatusNotDetermined) {
  } else if(status == kCLAuthorizationStatusAuthorizedAlways) {
    [self.locationManager startMonitoringForRegion: self.beaconRegion];
  } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
  }
}

@end
