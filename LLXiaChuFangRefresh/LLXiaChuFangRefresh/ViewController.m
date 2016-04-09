//
//  ViewController.m
//  LLXiaChuFangRefresh
//
//  Created by 李龙 on 16/4/7.
//  Copyright © 2016年 lauren. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat screenWidth;
    CGFloat originRefreshY;
    
    BOOL isRefresh;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UIView *refreshTextView;
@property (nonatomic,strong) UIView *activeBGView;

@property (nonatomic,strong) CAShapeLayer *pathLayer;
@property (nonatomic,strong) CALayer *animationLayer;

@property (nonatomic,strong) UIActivityIndicatorView *activityView;;


@end

@implementation ViewController

static NSString *const CellID = @"CellID";
static CGFloat const tableViewCellHeight = 60.f;
static CGFloat const tableViewHeaderViewHeight = 150.f;
static CGFloat const headerHeight = 35.f;
static int const tableViewRowOfNumber = 15;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    //表格
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
    _tableView.allowsSelection = NO;
    _tableView.tableFooterView = [UIView new];

    //刷新控件
    CGFloat refreshTextViewHeight = 40;
    
    isRefresh=NO;
 
    float scrollWidth = _tableView.frame.size.width;
    float labelWidth =130;
    
    _refreshTextView = ({
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_tableView.frame)-refreshTextViewHeight, screenWidth, refreshTextViewHeight)];
//        view.backgroundColor = [UIColor brownColor];
        
        //正在刷新中
        CGFloat _activityViewX = (scrollWidth-labelWidth)*0.5 - labelWidth;
        _activeBGView = [[UIView alloc] initWithFrame:view.bounds];
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.frame = CGRectMake(_activityViewX, 0, refreshTextViewHeight, refreshTextViewHeight);
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_activityViewX + refreshTextViewHeight +10, 0, labelWidth, CGRectGetHeight(_activeBGView.frame))];
        tipLabel.textColor = [UIColor blackColor];
        tipLabel.text = @"正在刷新~23333!!!";
        tipLabel.font = [UIFont systemFontOfSize:12];
        
        [_activeBGView addSubview:tipLabel];
        [_activeBGView addSubview:_activityView];
        [view addSubview:_activeBGView];
        [self.view addSubview:view];
        
        view;
    
    });
    originRefreshY = _refreshTextView.frame.origin.y;
    
    
    //设置动画
    self.animationLayer = [CALayer layer];
    self.animationLayer.frame = CGRectMake(0.0f, 0.0f,CGRectGetWidth(_refreshTextView.layer.bounds),CGRectGetHeight(_refreshTextView.layer.bounds));
    [_refreshTextView.layer addSublayer:self.animationLayer];
    
    
    self.animationLayer.hidden = NO;
    [self activeBGViewIsHidden:YES];
    
    //开始加载动画
    [self setupTextLayer];
    [self startAnimation];
    
}

- (void)activeBGViewIsHidden:(BOOL)hidden{
    self.activeBGView.hidden = hidden;
    self.activityView.hidden = hidden;
    
    if(!hidden){
        [_activityView startAnimating];
    }
    
}

#pragma mark UISCrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"scrollView:%@",NSStringFromCGPoint(scrollView.contentOffset));
    
    // 判断是否在拖动_scrollView
    CGRect rect = _refreshTextView.frame;
    rect.origin.y = originRefreshY - scrollView.contentOffset.y;
    _refreshTextView.frame = rect;
//    LxDBAnyVar(scrollView.contentOffset.y);
    
    CGFloat moveY = scrollView.contentOffset.y;
    if (scrollView.dragging) {
        if (fabs(moveY) < 50) {
            [self progressDragChangeValue:fabs(moveY)/5.0f];
        }else if(fabs(moveY) >= 50){
            [self progressDragChangeValue:10.0f];
        }
    }else{
        
        if (fabs(moveY) < 50) {
            [self progressDragChangeValue:fabs(moveY)/5.0f];
        }else{
            [self beginRefreshing];
        }
    }
    
}

- (void)progressDragChangeValue:(CGFloat)vlaue{
    
    self.pathLayer.timeOffset = vlaue;
}

- (void) startAnimation
{
    [self.pathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 10.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}

- (void) stopAnimation
{
    self.animationLayer.hidden = YES;
}

#pragma mark 下拉刷新开始和暂停
/**
 *  开始刷新操作  如果正在刷新则不做操作
 */
- (void)beginRefreshing
{
    if (!isRefresh) {
        isRefresh=YES;
        [self activeBGViewIsHidden:NO];
        
        // 设置刷新状态_scrollView的位置
        [UIView animateWithDuration:0.3 animations:^{
            //修改有时候refresh contentOffset 还在0，0的情况 20150723
            CGPoint point = _tableView.contentOffset;
            if (point.y >- headerHeight*1.5) {
                _tableView.contentOffset = CGPointMake(0, point.y-headerHeight*1.5);
            }
            _tableView.contentInset =  UIEdgeInsetsMake(headerHeight*1.5, 0, 0, 0);
        }];
        
        // 模拟网络数据请求
        [self simulateHTTPRequest];
        
        
        [self stopAnimation];
    }
    
    
}


- (void)simulateHTTPRequest{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}


- (void)endRefreshing
{
//    LxDBAnyVar(isRefresh);
    isRefresh=NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            CGPoint point= _tableView.contentOffset;
            if (point.y!=0) {
                _tableView.contentOffset=CGPointMake(0, point.y+headerHeight*1.5);
            }
            _tableView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
            
            
            [_activityView stopAnimating];
            [self activeBGViewIsHidden:YES];
            
            _animationLayer.hidden = NO;
        }];
    });
}


#pragma mark ---- 文字效果核心代码
- (void) setupTextLayer
{
    //原 Demo 地址:https://github.com/ole/Animated-Paths
    if (self.pathLayer != nil) {
        [self.pathLayer removeFromSuperlayer];
        self.pathLayer = nil;
    }
    
    // Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CTFontRef font = CTFontCreateWithName(CFSTR("HelveticaNeue-UltraLight"), 28.0f, NULL);//Helvetica-Bold
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"C'est La Vie"
                                                                     attributes:attrs];
    //C'est La Vie
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CGPathRelease(letters);
    CFRelease(font);
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.animationLayer.bounds;//设置位置
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);//设置位置
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [UIColor colorWithRed:234.0/255 green:84.0/255 blue:87.0/255 alpha:1].CGColor;
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineJoin = kCALineJoinBevel; //TODO 好像没啥用?
    
    pathLayer.speed = 0;
    pathLayer.timeOffset = 0;
    
    [self.animationLayer addSublayer:pathLayer];
    
    self.pathLayer = pathLayer;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return tableViewHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, tableViewHeaderViewHeight)];
    headerView.backgroundColor = [UIColor cyanColor];
    return headerView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
