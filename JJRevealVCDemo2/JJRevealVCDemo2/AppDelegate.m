//
//  AppDelegate.m
//  JJRevealVCDemo2
//
//  Created by 刘佳杰 on 16/11/3.
//  Copyright © 2016年 刘佳杰. All rights reserved.
//

#import "AppDelegate.h"
#import "JJRevealViewController.h"
#import "JJMainViewController.h"
#import "JJOtherViewController.h"
#import "JJOther2ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    JJRevealViewController *revealVC = [JJRevealViewController sharedRevealViewController];
    revealVC.tableViewWidth = 250;
    
    [revealVC addFrontViewController:[JJMainViewController new] withTitle:@"Main控制器"];
    
    [revealVC addFrontViewController:[JJOtherViewController new] withTitle:@"Other控制器"];
    
    [revealVC addFrontViewController:[JJOther2ViewController new] withTitle:@"Other2控制器"];
    
//    JJMainViewController *mainVC = [JJMainViewController new];
//    [revealVC addFrontViewController:mainVC withTitle:@"Main控制器"];
//    
//    JJOtherViewController *otherVC = [JJOtherViewController new];
//    [revealVC addFrontViewController:otherVC withTitle:@"Other控制器"];
//    
//    JJOther2ViewController *otherVC2 = [JJOther2ViewController new];
//    [revealVC addFrontViewController:otherVC2 withTitle:@"Other2控制器"];
    
    
//    JJRevealViewController *revealVC = [JJRevealViewController sharedRevealViewController];
//    [revealVC addFrontViewController:mainVC withTitle:@"Main控制器"];
//    revealVC.tableViewWidth = 250;
    
//    JJRevealViewController *revealVC = [[JJRevealViewController alloc] initWithFrontViewController:mainVC];
//    revealVC.tableViewWidth = 250;
    
    self.window.rootViewController = revealVC;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
