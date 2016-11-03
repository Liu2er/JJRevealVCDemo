//
//  JJRevealViewController.h
//  JJRevealVCDemo2
//
//  Created by 刘佳杰 on 16/11/3.
//  Copyright © 2016年 刘佳杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJRevealViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) CGFloat tableViewWidth;

+ (instancetype)sharedRevealViewController;
- (void)addFrontViewController:(UIViewController *)frontViewController withTitle:(NSString *)title;

@end
