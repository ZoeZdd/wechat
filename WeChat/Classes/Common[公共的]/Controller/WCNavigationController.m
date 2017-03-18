//
//  WCNavigationController.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/11/26.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCNavigationController.h"

@interface WCNavigationController ()

@end

@implementation WCNavigationController

+(void)initialize
{
    [self setupTheme];
}

+(void)setupTheme
{
    // 设置导航条背景
    UINavigationBar *navBar = [UINavigationBar appearance];
    UIImage *image = [UIImage imageNamed:@"topbarbg"];
    [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    // 设置全局状态栏样式
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置导航条标题的字体样式
    NSMutableDictionary *titleAtt = [NSMutableDictionary dictionary];
    
    titleAtt[NSFontAttributeName] = [ UIFont boldSystemFontOfSize:20];
    titleAtt[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [navBar setTitleTextAttributes:titleAtt];
    
    // 返回按钮的样式 白色
    [navBar setTintColor:[UIColor whiteColor]];
    
    // 设置导航栏item的样式
    NSMutableDictionary *itemAtt = [NSMutableDictionary dictionary];
    
    itemAtt[NSFontAttributeName] = [UIFont boldSystemFontOfSize:15];
    itemAtt[NSForegroundColorAttributeName] = [UIColor whiteColor];
    UIBarButtonItem *barItem = [UIBarButtonItem appearance];
    [barItem setTitleTextAttributes:itemAtt forState:UIControlStateNormal];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}
@end
