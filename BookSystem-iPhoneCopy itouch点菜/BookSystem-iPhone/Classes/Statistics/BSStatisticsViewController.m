//
//  BSStatisticsViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-25.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "BSStatisticsViewController.h"
#import "BSDataProvider.h"
#import "BSStatisticsCell.h"

@interface BSStatisticsViewController ()

@end

@implementation BSStatisticsViewController
@synthesize aryList;

- (void)dealloc{
    self.aryList = nil;
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNavBack];
    [self addBGColor:nil];
    [self setNavTitle:@"营运数据"];
    
	// Do any additional setup after loading the view.
    self.aryList = [NSArray arrayWithObjects:@"30001^100^24",@"30003^24^2",@"30004^56^38", nil];
    
    tvStatistics = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44)];
    tvStatistics.backgroundColor = [UIColor clearColor];
    tvStatistics.delegate = self;
    tvStatistics.dataSource = self;
    [self.view addSubview:tvStatistics];
    [tvStatistics release];
    
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FoodResultCell";
    BSStatisticsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[BSStatisticsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    cell.dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:[aryList objectAtIndex:indexPath.row],@"data", nil];

    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return aryList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 132;
}

@end
