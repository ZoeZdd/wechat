//
//  WCEditVCardViewController.h
//  WeChat
//
//  Created by 庄丹丹 on 2016/12/7.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WCEditVCardViewController;
@protocol WCEditVCardViewControllerDelegate <NSObject>

-(void)editVCardViewController:(WCEditVCardViewController *)editVc didFinishedSave:(id)sender;
@end
@interface WCEditVCardViewController : UITableViewController
/**
 *  上一个控制器(个人信息控制器)传入的cell
 */
@property(strong,nonatomic)UITableViewCell *cell;

@property(weak,nonatomic)id<WCEditVCardViewControllerDelegate> delegate;
@end
