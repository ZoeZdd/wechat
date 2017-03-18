//
//  WCContactCell.m
//  WeChat
//
//  Created by 庄丹丹 on 2017/3/17.
//  Copyright © 2017年 庄丹丹. All rights reserved.
//

#import "WCContactCell.h"

@interface WCContactCell ()
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;


@end
@implementation WCContactCell

- (void)awakeFromNib {
    // [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)contactCellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"WCContactCell";
    WCContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WCContactCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

-(void)setMFriend:(XMPPUserCoreDataStorageObject *)mFriend
{
    _mFriend = mFriend;
    
    // 有昵称用昵称，没有使用账号
    XMPPUserCoreDataStorageObject *friend = mFriend;
    NSString *displayName = friend.nickname;
    if (!friend.nickname) {
        displayName = friend.jid.user;
    }
    self.displayNameLabel.text = displayName;
    
}
@end
