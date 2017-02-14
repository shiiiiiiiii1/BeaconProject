//
//  RandomString.h
//  iBeaconCentral
//
//  Created by shoichi yokobori on 2017/02/14.
//  Copyright © 2017年 shoichi yokobori. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RandomString : NSObject

@property NSString *randomStr;   // インスタンス変数
/*
 @property
 これを宣言することで、自動で
 - getter
 - setter
 を生成してくれる。
 */

- (id)initWithLenght:(int)length;

@end
