//
//  TouchTableView.m
//  fanqieDian
//
//  Created by chenzhihui on 13-11-7.
//  Copyright (c) 2013年 chenzhihui. All rights reserved.
//

#import "TouchTableView.h"

@implementation TouchTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if ([self.touchDelegate conformsToProtocol:@protocol(TouchTableViewDelegate)]&&[self.touchDelegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)]) {
        [self.touchDelegate tableView:self touchesBegan:touches withEvent:event];
    }

}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    if ([self.touchDelegate conformsToProtocol:@protocol(TouchTableViewDelegate)]&&[self.touchDelegate respondsToSelector:@selector(tableView:touchesMoved:withEvent:)]) {
        [self.touchDelegate tableView:self touchesMoved:touches withEvent:event];
    }

}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    if ([self.touchDelegate conformsToProtocol:@protocol(TouchTableViewDelegate)]&&[self.touchDelegate respondsToSelector:@selector(tableView:touchesCancelled:withEvent:)]) {
        [self.touchDelegate tableView:self touchesCancelled:touches withEvent:event];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if ([self.touchDelegate conformsToProtocol:@protocol(TouchTableViewDelegate)]&&[self.touchDelegate respondsToSelector:@selector(tableView:touchesEnded:withEvent:)]) {
        [self.touchDelegate tableView:self touchesEnded:touches withEvent:event];
    }

}
@end



