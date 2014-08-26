//
//  LeftClassTableView.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-14.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "LeftClassTableView.h"
#import "BSDataProvider.h"

@implementation LeftClassTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadLeftTable" object:nil];
    }
    return self;
}
//刷新table通知方法
-(void)reloadTable{
    [self reloadData];
}
-(void)_init{
    BSDataProvider *dataPro = [BSDataProvider sharedInstance];
    classArray = [[NSMutableArray alloc] init];
    classArray = [[dataPro getClassList] retain];
    
    self.delegate = self;
    self.dataSource = self;
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
}

#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"typeResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    int count = 0;
    NSMutableArray *aryMutOrder = [[BSDataProvider sharedInstance] orderedFood];
    NSDictionary *dic =  [classArray objectAtIndex:indexPath.row];
    for (NSMutableDictionary *dict in aryMutOrder) {
        if ([[[dict objectForKey:@"food"] objectForKey:@"CLASS"] intValue] == [[dic objectForKey:@"GRP"] intValue] && ![[dict objectForKey:@"ISTC"] boolValue]) {
           count = count + [[dict objectForKey:@"total"] intValue];
        }else if ([[dict objectForKey:@"CLASS"] intValue] == [[dic objectForKey:@"GRP"] intValue] && [[dict objectForKey:@"ISTC"] boolValue]){
            count = count + [[dict objectForKey:@"total"] intValue];
        }
    }
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    
    cell.textLabel.text = [dic objectForKey:@"DES"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
    cell.detailTextLabel.textColor = [UIColor redColor];
    cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    NSString *strCount = @"";
    if (count > 0) {
        strCount = [NSString stringWithFormat:@"%d",count];
    }else{
        strCount = @"";
    }
    cell.detailTextLabel.text = strCount;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [classArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *typeID = [NSString stringWithFormat:@"%d",indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeTypeNotification" object:typeID];
}

-(void)dealloc{
    [super dealloc];
    classArray = nil;
    [classArray release];
}

@end
