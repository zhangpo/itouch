//
//  CardJuanClass.h
//  BookSystem
//
//  Created by sundaoran on 13-12-11.
//
//

#import <Foundation/Foundation.h>

@interface CardJuanClass : NSObject
{
    NSString *_JuanMoney;
    NSString *_JuanId;
    NSString *_JuanName;
    NSString *_JuanNum;
}

@property(nonatomic ,strong) NSString *JuanMoney;
@property(nonatomic ,strong) NSString *JuanId;
@property(nonatomic ,strong) NSString *JuanName;
@property(nonatomic ,strong) NSString *JuanNum;
@end
