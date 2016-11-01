//
//  JJRevealViewController.m
//  JJRevealVCDemo
//
//  Created by 刘佳杰 on 16/11/1.
//  Copyright © 2016年 刘佳杰. All rights reserved.
//

#import "JJRevealViewController.h"
#import "JJLeftViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface JJRevealViewController ()

@property (strong, nonatomic) JJLeftViewController *leftVC;

@end

@implementation JJRevealViewController

- (instancetype)initWithLeftViewController:(UIViewController *)leftViewController {
    if (self = [super init]) {
        _leftVC = (JJLeftViewController *)leftViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.view.layer.shadowColor =[UIColor darkGrayColor].CGColor;
    self.view.layer.shadowOpacity = 1;
    self.view.layer.shadowRadius =10;
    self.view.layer.shouldRasterize = YES;
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightGestureRespond:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGesture];
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftGestureRespond:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGesture];
}

- (void)swipeRightGestureRespond:(UISwipeGestureRecognizer *)gesture {
    NSLog(@"%s", __func__);
    [UIView animateWithDuration:0.15 animations:^{
        self.view.frame = CGRectMake(self.leftViewWidth, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.view.window insertSubview:self.leftVC.view atIndex:0];
    }];
    
}

- (void)swipeLeftGestureRespond:(UISwipeGestureRecognizer *)gesture {
    NSLog(@"%s", __func__);
    [UIView animateWithDuration:0.15 animations:^{
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}
@end
