//
//  AKShowPrivilegeView.m
//  BookSystem
//
//  Created by sundaoran on 13-12-2.
//
//

#import "AKShowPrivilegeView.h"


@implementation AKShowPrivilegeView
{
    NSArray *_dataArray;
}

@synthesize delegate=_delegate;

-(id)initWithArray:(NSArray *)FenLeiArray andSegmentArray:(NSArray *)SegmentArray
{       if(self=[super init])
    {
        _dataArray=[[NSArray alloc]initWithArray:SegmentArray];
        
        [self addSubview:[self creatView:FenLeiArray andSegmentArray:SegmentArray]];
        self.userInteractionEnabled=YES;
    }
    return self;
}

-(UIView *)creatView:(NSArray *)FenLeiArray andSegmentArray:(NSArray *)SegmentArray
{
    NSMutableArray *liteArray=[[NSMutableArray alloc]init];
    NSMutableArray *dataArray=[[NSMutableArray alloc]init];
    for (int num=0; num<[FenLeiArray count]; num++)
    {
        NSString *str=((AKsFenLeiClass*)[FenLeiArray objectAtIndex:num]).fenLeiName;
        if(num%5==0 && num!=0)
        {
            [dataArray addObject:liteArray];
            liteArray=[[NSMutableArray alloc]init];
        }
        [liteArray addObject:str];
        if(num%5!=0 && num==[FenLeiArray count]-1)
        {
            [dataArray addObject:liteArray];
        }
    }
    int fenleiLine;
    if([FenLeiArray count]%5==0)
    {
        fenleiLine=[FenLeiArray count]/5;
    }
    else
    {
        fenleiLine=[FenLeiArray count]/5+1;
    }
    
    for (int i=0; i<fenleiLine; i++)
    {
        UISegmentedControl *segment=[[UISegmentedControl alloc]initWithFrame:CGRectMake(0, i*60, 430, 50)];
        segment.tag=i*5;
        for (int d=0; d<[[dataArray objectAtIndex:i]count]; d++)
        {
            [segment insertSegmentWithTitle:[[dataArray objectAtIndex:i]objectAtIndex:d] atIndex:d animated:NO];
        }
        [segment addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:segment];
    }
    
    UIScrollView *view=[[UIScrollView alloc]initWithFrame:CGRectMake(0,fenleiLine*60,430, 600+50)];
    view.backgroundColor=[UIColor clearColor];
    
    NSMutableArray *shortLength=[[NSMutableArray alloc]init];
    NSMutableArray *longLength=[[NSMutableArray alloc]init];
    
    for (AKsSettlementClass *settlement in SegmentArray)
    {
        NSString *str=[[NSString alloc]initWithString:settlement.SettlementName];
        if([str length]<=4)
        {
            [shortLength addObject:str];
        }
        else
        {
            [longLength addObject:str];
        }
    }
    
    for (int i=0; i<[shortLength count]; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
        button.tag=i;
        [button setTitle:((AKsSettlementClass *)[SegmentArray objectAtIndex:button.tag]).SettlementName forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        button.frame=CGRectMake(10+i%3*140, 10+i/3*80, 130, 70);
        [button addTarget:self action:@selector(ButonClick:) forControlEvents:UIControlEventTouchUpInside];
        view.contentSize=CGSizeMake(430, (i/3+1)*80);
        [view addSubview:button];
    }
    
    for (int i=[shortLength count]; i<[shortLength count]+[longLength count]; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
        button.tag=i;
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        [button addTarget:self action:@selector(ButonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:((AKsSettlementClass *)[SegmentArray objectAtIndex:button.tag]).SettlementName forState:UIControlStateNormal];
        int temp2=i-[shortLength count];
        if([shortLength count]%3!=0)
        {
            button.frame=CGRectMake(10+temp2%2*210,temp2/2*80+([shortLength count]/3+1)*80+10, 200, 70);
        }
        else
        {
            button.frame=CGRectMake(10+temp2%2*210,temp2/2*80+([shortLength count]/3)*80+10, 200, 70);
        }
        [view addSubview:button];
    }
    view.contentSize=CGSizeMake(430, (([shortLength count]/3+[longLength count]/2)+2)*80);
    return view;
}

-(void)segmentClick:(UISegmentedControl *)segment
{
    int selectIndex=segment.selectedSegmentIndex+segment.tag;
    [_delegate changeSegmentSelect:selectIndex];
    
}

-(void)setCanuse:(BOOL)use
{
    self.userInteractionEnabled=use;
}

-(void)ButonClick:(UIButton *)button
{
    [_delegate changeButtonSelect:((AKsSettlementClass *)[_dataArray objectAtIndex:button.tag])];
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
