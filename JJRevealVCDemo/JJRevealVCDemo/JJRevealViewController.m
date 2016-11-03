//
//  JJRevealViewController.m
//  JJRevealVCDemo
//
//  Created by 刘佳杰 on 16/11/1.
//  Copyright © 2016年 刘佳杰. All rights reserved.
//

#import "JJRevealViewController.h"
#import "JJLeftViewController.h"
#import "UIView+Layout.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface JJRevealViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) JJLeftViewController *leftVC;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (assign, nonatomic) CGFloat transformScale;

// YES代表原来大小，NO代表向右缩小了
@property (assign, nonatomic) BOOL isRevealViewOpen;

@end

@implementation JJRevealViewController

- (instancetype)initWithLeftViewController:(UIViewController *)leftViewController {
    if (self = [super init]) {
        _leftVC = (JJLeftViewController *)leftViewController;
        _transformScale = 0.8;
        _isRevealViewOpen = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.view.layer.shadowColor =[UIColor darkGrayColor].CGColor;
    self.view.layer.shadowOpacity = 1;
    self.view.layer.shadowRadius =10;
    self.view.layer.shouldRasterize = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGesture];
    self.panGesture = panGesture;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    self.tapGesture = tapGesture;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    // 获得手指移动的偏移量
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    
    // 获得偏移后的视图的左边位置，直接用self.view也行
    CGFloat viewCenterX = recognizer.view.centerX + translatedPoint.x;
    
    CGFloat fromCenterX = SCREEN_WIDTH / 2.0;
    CGFloat toCenterX = self.leftViewWidth + SCREEN_WIDTH * self.transformScale / 2.0;
    CGFloat middleCenterX = fromCenterX + (toCenterX - fromCenterX) / 2.0;
    
    if (viewCenterX >= toCenterX) {  // 设置最右边边界
        recognizer.view.centerX = toCenterX;
    } else if (viewCenterX <= fromCenterX) {  // 设置最左边边界
        recognizer.view.centerX = fromCenterX;
    } else {  // 在有效边界范围内：view跟指，且按比例缩放
        recognizer.view.centerX = viewCenterX;
        
        // 希望transformScale的范围是1~0.8，view的位移范围是fromCenterX~toCenterX
        // 利用两点式方程求即：x = (y-y1)/(y2-y1)*(x2-x1)+x1，其中(x1,y1)=(1,fromCenterX)，(x2,y2)=(self.transformScale,toCenterX)，y=viewCenterX,待求的x=scale
        CGFloat scale = (viewCenterX - fromCenterX) / (toCenterX - fromCenterX) * (self.transformScale - 1) + 1;
        recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
//        self.leftVC.tableView.layer.anchorPoint = CGPointMake(0.5, 0);
        self.leftVC.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    }
    
    // 当超过指定的中间边界后，view自动贴到边上去
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (viewCenterX > middleCenterX) {  // view的左边向右超过了中间线就自动贴到右边
            [UIView animateWithDuration:0.1 animations:^{
                // 此处也有下面的问题，但可以忽略
                recognizer.view.centerX = toCenterX;
                recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.transformScale, self.transformScale);
            } completion:^(BOOL finished) {
                self.isRevealViewOpen = NO;
                
                
                [self.view.window insertSubview:self.leftVC.view atIndex:0];
            }];
        } else {
            [UIView animateWithDuration:0.1 animations:^{  // view的左边向左超过了中间线就自动贴到左边
                // 由于锚点为view的中心点，而满足进到此代码段的条件时recognizer.view还没有回到屏幕大小，此时以中心为锚点按比例放大会导致整个view左偏
                recognizer.view.centerX = fromCenterX;
                recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            } completion:^(BOOL finished) {
                self.isRevealViewOpen = YES;
            }];
        }
    }
    
    // 视图该移动到指定位置后，一次结束就清零一次
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    if (!self.isRevealViewOpen && recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            // 用recognizer.view.left = 0;的方式会因为锚点原因导致往左偏
            recognizer.view.centerX = SCREEN_WIDTH / 2.0;
            recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        } completion:^(BOOL finished) {
            self.isRevealViewOpen = YES;
        }];
    }
    
    if (self.isRevealViewOpen && recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            // 用recognizer.view.left = 0;的方式会因为锚点原因导致往左偏
            recognizer.view.centerX = self.leftViewWidth + SCREEN_WIDTH * self.transformScale / 2.0;
            recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.transformScale, self.transformScale);
        } completion:^(BOOL finished) {
            self.isRevealViewOpen = NO;
        }];
    }
}

//- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
//    // 获得手指移动的偏移量
//    CGPoint translatedPoint = [recognizer translationInView:self.view];
//
//    // 获得偏移后的视图的左边位置，直接用self.view也行
//    CGFloat viewLeft = recognizer.view.left + translatedPoint.x;
//    
//    if (viewLeft >= self.leftViewWidth) {  // 设置最右边边界
//        recognizer.view.left = self.leftViewWidth;
//    } else if (viewLeft <= 0) {  // 设置最左边边界
//        recognizer.view.left = 0;
//    } else {  // 在有效边界范围内：view跟指，且按比例缩放
//        recognizer.view.left = viewLeft;
//
//        // 希望transformScale的范围是1~0.8，view的位移范围是0~300，从而根据对应关系计算出1200
//        CGFloat scale = 1 - recognizer.view.left / (self.leftViewWidth / (1 - self.transformScale));
//        recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
//    }
//
//    // 当超过指定的中间边界后，view自动贴到边上去
//    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
//        if (viewLeft > self.leftViewWidth / 2.0) {  // view的左边向右超过了中间线就自动贴到右边
//            [UIView animateWithDuration:0.2 animations:^{
//                // 此处也有下面的问题，但可以忽略
//                recognizer.view.left = self.leftViewWidth;
//                recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.transformScale, self.transformScale);
//            }];
//        } else {
//            [UIView animateWithDuration:0.2 animations:^{  // view的左边向左超过了中间线就自动贴到左边
//                // 由于锚点为view的中心点，而满足进到此代码段的条件时recognizer.view还没有回到屏幕大小，此时以中心为锚点按比例放大会导致整个view左偏
//                recognizer.view.centerX = SCREEN_WIDTH / 2.0;
//                recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
//            } completion:^(BOOL finished) {
//
//            }];
//        }
//    }
//
//    // 视图该移动到指定位置后，一次结束就清零一次
//    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
//}
@end
