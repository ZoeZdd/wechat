//
//  WCContactCell.h
//  WeChat
//
//  Created by 庄丹丹 on 2017/3/17.
//  Copyright © 2017年 庄丹丹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPUserCoreDataStorageObject.h"

@interface WCContactCell : UITableViewCell
+(instancetype)contactCellWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UIImageView *headView;

@property (weak, nonatomic) IBOutlet UILabel *sectionNumLabel;

@property (nonatomic,strong) XMPPUserCoreDataStorageObject *mFriend;

@end
