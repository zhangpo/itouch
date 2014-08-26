//
//  AKsIsVipShowView.m
//  BookSystem
//
//  Created by sundaoran on 14-2-15.
//
//

#import "AKsIsVipShowView.h"

@implementation AKsIsVipShowView

- (id)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.frame=CGRectMake(768-350, 44, 330, 130);
        //        self.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vipmessage.png"]];
        imageView.frame=CGRectMake(0, 0, 330, 120);
        [self addSubview:imageView];
        
        if([array count]!=1)
        {
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(120,0, self.bounds.size.width-120, self.bounds.size.height)];
            label.text=@"暂无信息";
            label.textAlignment=UITextAlignmentCenter;
            label.font=[UIFont boldSystemFontOfSize:20];
            [self addSubview:label];
        }
        else
        {
            for (NSDictionary *dict in array)
            {
                NSString *cardNum=[NSString stringWithFormat:@"%@",[dict objectForKey:@"cardNum"]];
                NSString *phoneNum=[NSString stringWithFormat:@"%@",[dict objectForKey:@"phoneNum"]];
                
                UILabel *labelPhoneName=[[UILabel alloc]initWithFrame:CGRectMake(147, 32, 110, 35)];
                labelPhoneName.textColor=[UIColor grayColor];
                if([phoneNum isEqualToString:@""] || [phoneNum isEqualToString:@"null"]|| [phoneNum isEqualToString:@"(null)"]|| [phoneNum isEqualToString:@"NULL"])
                {
                    labelPhoneName.text=@"暂无信息";
                }
                else
                {
                    labelPhoneName.text=phoneNum;
                }
                
                [self addSubview:labelPhoneName];
                
                UILabel *labelcardName=[[UILabel alloc]initWithFrame:CGRectMake(147, 69, 160, 35)];
                labelcardName.textColor=[UIColor grayColor];
                if([cardNum isEqualToString:@""] || [cardNum isEqualToString:@"null"]|| [cardNum isEqualToString:@"(null)"]|| [cardNum isEqualToString:@"NULL"]|| [cardNum isEqualToString:@"1"])
                {
                    labelcardName.text=@"暂无信息";
                }
                else
                {
                    labelcardName.text=cardNum;
                }
                [self addSubview:labelcardName];
            }
        }
        
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

@end
