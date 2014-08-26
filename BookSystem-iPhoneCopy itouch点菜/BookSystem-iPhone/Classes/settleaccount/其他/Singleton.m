//
//  Singleton.m
//  BookSystem
//
//  Created by chensen on 13-11-22.
//
//

#import "Singleton.h"

@implementation Singleton
@synthesize dishArray=_dishArray,order=_order;
@synthesize userInfo=_userInfo;
@synthesize Seat=_Seat,CheckNum=_CheckNum,man=_man,woman=_woman,quandan=_quandan;
@synthesize isYudian=_isYudian,userName=_userName;
static Singleton *_sharedSingleton;
+(Singleton *)sharedSingleton
{
    if (!_sharedSingleton) {
        _sharedSingleton=[[Singleton alloc] init];
    }
    return _sharedSingleton;
}

@end
