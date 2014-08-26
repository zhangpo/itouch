//
//  AKsNewVipMessageShowView.m
//  BookSystem
//
//  Created by sundaoran on 14-3-5.
//
//

#import "AKsNewVipMessageShowView.h"

@implementation AKsNewVipMessageShowView
{
    UIView *_view;
    UIView *_showMessageView;
    NSMutableArray *buttonArray;
}

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor blackColor];
        self.layer.cornerRadius=5;
        
        
        [self chushihua];
        [self greatView];
        
        
    }
    return self;
}
-(void)chushihua
{
    _view=[[UIView alloc]init];
    CGRect rect=self.bounds;
    _view.frame=CGRectMake(rect.origin.x+3, rect.origin.y+3, rect.size.width-6, rect.size.height-6);
    _view.layer.cornerRadius=5;
    _view.backgroundColor=[UIColor whiteColor];
    [self addSubview:_view];
    
    _showMessageView=[[UIView alloc]init];
    rect=self.bounds;
    _showMessageView.layer.cornerRadius=5;
    _showMessageView.frame=CGRectMake(rect.origin.x+5, 45, rect.size.width-16, rect.size.height-55);
    _showMessageView.backgroundColor=[UIColor colorWithRed:193/255.0f green:193/255.0f blue:193/255.0f alpha:1];
    [_view addSubview:_showMessageView];
    

    buttonArray =[[NSMutableArray alloc]init];
    
}

-(void)greatView
{
    NSArray *array=[[NSArray alloc]initWithObjects:@"会员持卡",@"电子优惠劵",@"消费情况",@"交易情况", nil];
    
    for (int i=0; i<[array count]; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(((728-68)/4+1)*i+5, 7, (728-68)/4, 40);
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        i==0?[button setBackgroundImage:[UIImage imageNamed:@"blackButton.png"] forState:UIControlStateNormal]:[button setBackgroundImage:[UIImage imageNamed:@"whiteButton.png"] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:button];
        button.tag=1000+i;
        [buttonArray addObject:button];
    }
    
}

-(void)selectButton:(UIButton *)btn
{
    for (UIButton *button in buttonArray)
    {
        button==btn?[button setBackgroundImage:[UIImage imageNamed:@"blackButton.png.png"] forState:UIControlStateNormal]:[button setBackgroundImage:[UIImage imageNamed:@"whiteButton.png"] forState:UIControlStateNormal];
    }
    
    [_delegate segmentButtonClick:btn.tag];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
