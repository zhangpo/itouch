//
//  AKShowPrivilegeView.h
//  BookSystem
//
//  Created by sundaoran on 13-12-2.
//
//

//优惠类别
#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "AKsFenLeiClass.h"
#import "AKsSettlementClass.h"

@protocol AKShowPrivilegeViewDelegate <NSObject>

@optional

-(void)changeSegmentSelect:(NSInteger )selectIndex;
-(void)changeButtonSelect:(AKsSettlementClass *)selectButton;

@end

@interface AKShowPrivilegeView : UIView<AKShowPrivilegeViewDelegate>
{
     id<AKShowPrivilegeViewDelegate>_delegate;
}

@property(nonatomic,retain) id<AKShowPrivilegeViewDelegate> delegate;

-(id)initWithArray:(NSArray *)FenLeiArray andSegmentArray:(NSArray *)SegmentArray;
-(void)setCanuse:(BOOL)use;
@end
