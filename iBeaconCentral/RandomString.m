//
//  RandomString.m
//  iBeaconCentral
//
//  Created by shoichi yokobori on 2017/02/14.
//  Copyright © 2017年 shoichi yokobori. All rights reserved.
//

#import "RandomString.h"


@interface RandomString()

@end


@implementation RandomString

- (id)initWithLenght:(int)length
{
  self = [super init];
  if(self) {
    // initialize処理
    NSString *chars = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJLKMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomStr = [NSMutableString string];
    for (int i = 0; i < length; i++) {
      int index = arc4random_uniform((int)chars.length);
      [randomStr appendString:[chars substringWithRange:NSMakeRange(index, 1)]];
    }
    self.randomStr = randomStr;
  }
  return self;
}

- (id)init
{
  return [self initWithLenght:6];
}

@end
