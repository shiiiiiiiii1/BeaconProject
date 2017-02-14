//
//  TimeCounter.m
//  iBeaconCentral
//
//  Created by shoichi yokobori on 2017/02/15.
//  Copyright © 2017年 shoichi yokobori. All rights reserved.
//

#import "TimeCounter.h"


@implementation TimeCounter

- (id)initWithTime:(int)countVal
{
  self = [super init];
  if(self) {
    // initialize処理
    self.countVal = countVal;
  }
  return self;
}

- (id)init
{
  return [self initWithTime:20];
}

@end
