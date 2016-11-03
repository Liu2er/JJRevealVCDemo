//
//  JJRevealViewController.m
//  JJRevealVCDemo2
//
//  Created by 刘佳杰 on 16/11/3.
//  Copyright © 2016年 刘佳杰. All rights reserved.
//

#import "JJRevealViewController.h"
#import "UIView+Layout.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static const float headerHeight = 150;
static const float footerHeight = 150;

@interface JJRevealViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *frontView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (assign, nonatomic) CGFloat frontViewTransformScale;
@property (assign, nonatomic) CGFloat tableViewTransformScale;

// YES代表原来大小，NO代表向右缩小了
@property (assign, nonatomic) BOOL isRevealViewOpen;

@property (strong, nonatomic) NSMutableDictionary *dataSource;

@end


@implementation JJRevealViewController

+ (instancetype)sharedRevealViewController {
    static JJRevealViewController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [JJRevealViewController new];
    });
    return instance;
}

- (NSMutableDictionary *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableDictionary new];
    }
    return _dataSource;
}

- (void)addFrontViewController:(UIViewController *)frontViewController withTitle:(NSString *)title {
    if (![self.dataSource.allValues containsObject:frontViewController]) {
        [self.dataSource setObject:frontViewController forKey:title];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDefaultData];
    [self setBackgroudImage];
    [self initTableView];
    [self initFrontView];
    [self showFirstView];
}

- (void)initDefaultData {
    self.frontViewTransformScale = 0.8;
    self.tableViewTransformScale = 0.8;
    self.isRevealViewOpen = YES;
}

- (void)setBackgroudImage {
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.image = [UIImage imageNamed:@"backgroundImage2"];
    [self.view addSubview:imageview];
}

- (void)initTableView {
    CGFloat tableViewHeight = 44 * self.dataSource.count + headerHeight + footerHeight;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT - tableViewHeight)/2.0, self.tableViewWidth, tableViewHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // tableView默认选中第一行
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    [self.view addSubview:self.tableView];
}

// 默认显示第一个控制器的view
- (void)showFirstView {
    NSArray *viewControllers = [self getAllValuesInDataSource:self.dataSource];
    UIViewController *viewController = viewControllers[0];
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.frontView addSubview:viewController.view];
}

- (void)initFrontView {
    self.frontView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.frontView.layer.shadowColor =[UIColor blackColor].CGColor;
    self.frontView.layer.shadowOpacity = 1.0f;
    self.frontView.layer.shadowRadius = 2.5f;
    self.frontView.layer.shadowOffset = CGSizeMake(0.0f, 2.5f);
    // 当shouldRasterize设成YES时，layer被渲染成一个bitmap，并缓存起来，等下次使用时不会再重新去渲染了，直接从渲染引擎的cache里读取那张bitmap，节约系统资源。
    self.frontView.layer.shouldRasterize = YES;
    //    self.frontView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.frontView];
}

#pragma mark - Animation

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [self.frontView addGestureRecognizer:panGesture];
    self.panGesture = panGesture;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [self.frontView addGestureRecognizer:tapGesture];
    self.tapGesture = tapGesture;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    // 获得手指移动的偏移量
    CGPoint translatedPoint = [recognizer translationInView:self.frontView];
    
    // 获得偏移后的视图的左边位置，直接用self.view也行
    CGFloat viewCenterX = recognizer.view.centerX + translatedPoint.x;
    
    CGFloat fromCenterX = SCREEN_WIDTH / 2.0;
    CGFloat toCenterX = self.tableViewWidth + SCREEN_WIDTH * self.frontViewTransformScale / 2.0;
    CGFloat middleCenterX = fromCenterX + (toCenterX - fromCenterX) / 2.0;
    
    if (viewCenterX >= toCenterX) {  // 设置最右边边界
        recognizer.view.centerX = toCenterX;
    } else if (viewCenterX <= fromCenterX) {  // 设置最左边边界
        recognizer.view.centerX = fromCenterX;
    } else {  // 在有效边界范围内：view跟指，且按比例缩放
        recognizer.view.centerX = viewCenterX;
        
        // 希望frontViewTransformScale的范围是1~0.8，view的位移范围是fromCenterX~toCenterX
        // 利用两点式方程求即：x = (y-y1)/(y2-y1)*(x2-x1)+x1，其中(x1,y1)=(1,fromCenterX)，(x2,y2)=(self.frontViewTransformScale,toCenterX)，y=viewCenterX,待求的x=scale
        CGFloat scale = (viewCenterX - fromCenterX) / (toCenterX - fromCenterX) * (self.frontViewTransformScale - 1) + 1;
        recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
        CGFloat scale2 = (scale - 1) / (self.frontViewTransformScale - 1) * (1 - self.tableViewTransformScale) + self.tableViewTransformScale;
        self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale2, scale2);
        self.tableView.right = recognizer.view.left;
    }
    
    // 当超过指定的中间边界后，view自动贴到边上去
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (viewCenterX > middleCenterX) {  // 贴到右边
            [UIView animateWithDuration:0.1 animations:^{
                // 此处也有下面的问题，但可以忽略
                recognizer.view.centerX = toCenterX;
                recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.frontViewTransformScale, self.frontViewTransformScale);
                self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                self.tableView.right = recognizer.view.left;
            } completion:^(BOOL finished) {
                self.isRevealViewOpen = NO;
            }];
        } else {
            [UIView animateWithDuration:0.1 animations:^{  // 贴到左边
                // 由于锚点为view的中心点，而满足进到此代码段的条件时recognizer.view还没有回到屏幕大小，此时以中心为锚点按比例放大会导致整个view左偏
                recognizer.view.centerX = fromCenterX;
                recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.tableViewTransformScale, self.tableViewTransformScale);
                self.tableView.right = recognizer.view.left;
            } completion:^(BOOL finished) {
                self.isRevealViewOpen = YES;
            }];
        }
    }
    
    // 视图该移动到指定位置后，一次结束就清零一次
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    // frontView变大，即关闭左侧菜单
    if (!self.isRevealViewOpen && recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            // 用recognizer.view.left = 0;的方式会因为锚点原因导致往左偏
            recognizer.view.centerX = SCREEN_WIDTH / 2.0;
            recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.tableViewTransformScale, self.tableViewTransformScale);
            self.tableView.right = recognizer.view.left;
        } completion:^(BOOL finished) {
            self.isRevealViewOpen = YES;
        }];
    }
    
//    // frontView变小，即打开左侧菜单
//    if (self.isRevealViewOpen && recognizer.state == UIGestureRecognizerStateEnded) {
//        [UIView animateWithDuration:0.2 animations:^{
//            // 用recognizer.view.left = 0;的方式会因为锚点原因导致往左偏
//            recognizer.view.centerX = self.tableViewWidth + SCREEN_WIDTH * self.frontViewTransformScale / 2.0;
//            recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.frontViewTransformScale, self.frontViewTransformScale);
//            self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
//            self.tableView.right = recognizer.view.left;
//        } completion:^(BOOL finished) {
//            self.isRevealViewOpen = NO;
//        }];
//    }
}

#pragma  maek - UITableViewDelegate UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return footerHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LeftViewControllerCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:20];
    }
    
    NSArray *keys = [self getAllKeysInDataSource:self.dataSource];
    cell.textLabel.text = keys[indexPath.row];
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.frontView removeAllSubviews];
    NSArray *viewControllers = [self getAllValuesInDataSource:self.dataSource];
    UIViewController *viewController = viewControllers[indexPath.row];
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.frontView addSubview:viewController.view];
}


- (NSArray<NSString *> *)getAllKeysInDataSource:(NSMutableDictionary *)dataSource {
    NSArray *keys = [NSArray array];
    // ???
    if (!dataSource) {
        return nil;
    }
    keys = [self.dataSource allKeys];
    return keys;
}

- (NSArray<UIViewController *> *)getAllValuesInDataSource:(NSMutableDictionary *)dataSource {
    NSArray *viewControllers = [NSArray array];
    // ???
    if (!dataSource) {
        return nil;
    }
    viewControllers = [self.dataSource allValues];
    return viewControllers;
}
@end
