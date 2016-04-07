//
//  ViewController.m
//  LLXiaChuFangRefresh
//
//  Created by 李龙 on 16/4/7.
//  Copyright © 2016年 lauren. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat screenWidth;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UIView *refreshView;
@end

@implementation ViewController

static NSString *const CellID = @"CellID";
static CGFloat const tableViewCellHeight = 60.f;
static int const tableViewRowOfNumber= 6;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
    _tableView.allowsSelection = NO;
    _tableView.tableFooterView = [UIView new];

    _refreshView = ({
        CGFloat refreshViewHeight = 40;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_tableView.frame), screenWidth, refreshViewHeight)];
        view.backgroundColor = [UIColor brownColor];
        
        [self.view addSubview:view];
        view;
    
    });
    
}



#pragma mark UItableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableViewRowOfNumber;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"LeftTableView:%zd",indexPath.row];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return tableViewCellHeight;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"LeftTableView 点击了 %zd-------%zd",indexPath.section,indexPath.row);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
