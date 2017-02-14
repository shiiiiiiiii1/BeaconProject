//
//  ViewController.m
//  iBeaconCentral
//
//  Created by shoichi yokobori on 2017/02/11.
//  Copyright © 2017年 shoichi yokobori. All rights reserved.
//

#import "ViewController.h"
#import "RandomString.h"
#import "TimeCounter.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@property RandomString *randomString;
@property TimeCounter *timeCounter;

@property int time;

@end


@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
    // CLLocationManagerの生成とデリゲートの設定
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"5A506336-4948-4AFD-A2CD-29F549B25546"];   // app調べ

    // CLBeaconRegionを作成
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"shiiiiiiiii1"];

    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
      [self.locationManager requestAlwaysAuthorization];
    } else {
      // Beaconによる領域観測を開始
      [self.locationManager startMonitoringForRegion: self.beaconRegion];
    }
  } else {
    NSLog(@"お使いの端末ではiBeaconを利用できません。");
  }

// 爆弾止めるキーの生成
  self.randomString = [[RandomString alloc] initWithLenght:3];
// タイマーの時間をセット
  self.time = 10;
  self.timeCounter = [[TimeCounter alloc] initWithTime:self.time];

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
  NSLog(@"Enter Region");

  if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
    [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
  }
}

// 領域から退出した場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  // ローカル通知
  NSLog(@"Exit Region");
  
  // Beaconの距離測定を終了する
  if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
    [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    NSLog(@"End communication");
  }
}

/* 距離イベントのハンドリング */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
  if (beacons.count > 0) {
    // 最も距離の近いBeaconについて処理する
    CLBeacon *nearestBeacon = beacons.firstObject;
    NSString *rangeMessage;
    
    [self timerUpdate:region];
    // Beacon の距離でメッセージを変える
    switch (nearestBeacon.proximity) {
      case CLProximityImmediate:
        rangeMessage = @"Range:Immediate";
        _randomStr.text = self.randomString.randomStr;
        break;
      case CLProximityNear:
        rangeMessage = @"Range:Near";
        _randomStr.text = @"";
        break;
      case CLProximityFar:
        rangeMessage = @"Range:Far";
        _randomStr.text = @"";
        break;
      default:
        rangeMessage = @"Range:Unknown";
        _randomStr.text = @"";
        break;
    }
    
    // ローカル通知
    NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%ld", nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, (long)nearestBeacon.rssi];

    NSLog(@"%@ %@", rangeMessage, message);
  }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
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




// 爆弾タイマーの更新
- (void)timerUpdate:(CLBeaconRegion *)region
{
  if (self.timeCounter.countVal > 0) {
    _timer.text = [NSString stringWithFormat:@"%d", self.timeCounter.countVal--];
  } else if ( self.timeCounter.countVal == 0 ) {
    _timer.text = @"BOOOMB!!!!!";
    [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
  }
}

// ボタン押したら値取得
- (IBAction)sendText:(id)sender
{
  NSString *randomStr = self.randomString.randomStr;
  NSString *inputStr = self.textField.text;
  if ([randomStr isEqualToString:inputStr]) {
    [self timerStop:self.beaconRegion];
  }
}

// タイマーstop処理
- (void)timerStop:(CLBeaconRegion *)region
{
  _timer.text = @"Success!!!";
  [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
  
}


@end
