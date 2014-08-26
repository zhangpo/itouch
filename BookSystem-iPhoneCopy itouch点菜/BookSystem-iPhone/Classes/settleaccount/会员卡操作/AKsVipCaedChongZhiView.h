//
//  AKsVipCaedChongZhiView.h
//  BookSystem
//
//  Created by sundaoran on 13-12-11.
//
//

#import "BSRotateView.h"

@protocol AKsVipCaedChongZhiViewDelegate <NSObject>

-(void)sureVipChongZhi:(NSString *)money;
-(void)cancleVipChongZhi;

@end

@interface AKsVipCaedChongZhiView : BSRotateView
{
     id<AKsVipCaedChongZhiViewDelegate>_delegate;
}
@property(nonatomic,retain) id<AKsVipCaedChongZhiViewDelegate>delegate;

@end
