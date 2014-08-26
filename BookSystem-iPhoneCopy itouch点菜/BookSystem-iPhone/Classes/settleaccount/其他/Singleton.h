//
//  Singleton.h
//  BookSystem
//
//  Created by chensen on 13-11-22.
//
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject
{
    BOOL     _isYudian;
}
@property(nonatomic,retain)NSMutableArray *dishArray;
@property(nonatomic,strong)NSDictionary *userInfo;
@property(nonatomic,copy)NSString *Seat;
@property(nonatomic,copy)NSString *CheckNum;
@property(nonatomic,copy)NSString *Time;
@property(nonatomic,copy)NSString *man;
@property(nonatomic,copy)NSString *woman;
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,assign)int segment;
@property(nonatomic,retain)NSMutableArray *order;
@property(nonatomic,assign)BOOL quandan;

@property(nonatomic)BOOL isYudian;
+(Singleton *)sharedSingleton;
@end
