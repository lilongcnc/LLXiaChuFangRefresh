//
//  ViewController.m
//  LLXiaChuFangRefresh
//
//  Created by 李龙 on 16/4/7.
//  Copyright © 2016年 lauren. All rights reserved.
//

#import "ViewController.h"
#import "LxDBAnything.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat screenWidth;
    CGFloat originRefreshY;
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
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_tableView.frame)-refreshViewHeight, screenWidth, refreshViewHeight)];
        view.backgroundColor = [UIColor brownColor];
        
        [self.view addSubview:view];
        view;
    
    });
    
    
    
    originRefreshY = _refreshView.frame.origin.y;
    
}
#pragma mark UISCrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    // 获取_scrollView的contentSize
//    contentHeight=scrollView.contentSize.height;
    
    // 判断是否在拖动_scrollView
//    if (scrollView.dragging) {
        NSLog(@"scrollView:%@",NSStringFromCGPoint(scrollView.contentOffset));
        
        CGRect rect = _refreshView.frame;
        rect.origin.y = originRefreshY - scrollView.contentOffset.y;
        _refreshView.frame = rect;
    
//    }else{
//        
//    }
    
    
//    [self.view setNeedsLayout];
}

#pragma mark - 刷新当前界面布局
-(void)viewWillLayoutSubviews{
    
 NSLog(@"%s",__FUNCTION__);
    
    
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
