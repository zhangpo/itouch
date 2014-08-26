//
//  AKsNewVipMessageShowView.h
//  BookSystem
//
//  Created by sundaoran on 14-3-5.
//
//

#import <UIKit/UIKit.h>

@protocol AKsNewVipMessageShowViewDelegate <NSObject>

-(void)segmentButtonClick:(int)buttonTag;


@end

@interface AKsNewVipMessageShowView : UIView
{
    id <AKsNewVipMessageShowViewDelegate> _delegate;
}

@property(nonatomic,strong)id<AKsNewVipMessageShowViewDelegate>delegate;

@end
