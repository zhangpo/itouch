//
//  AKsUserPaymentClass.h
//  BookSystem
//
//  Created by sundaoran on 14-1-9.
//
//

#import <Foundation/Foundation.h>

@interface AKsUserPaymentClass : NSObject
{
    NSString *_userpaymentName;
    NSString *_userpaymentMoney;
    NSString *_userpaymentTag;
    NSString *_userpaymentCount;
}


@property(nonatomic,strong) NSString *userpaymentName;
@property(nonatomic,strong) NSString *userpaymentMoney;
@property(nonatomic,strong) NSString *userpaymentTag;
@property(nonatomic,strong) NSString *userpaymentCount;
@end
