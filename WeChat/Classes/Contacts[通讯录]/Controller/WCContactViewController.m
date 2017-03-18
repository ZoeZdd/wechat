//
//  WCContactViewController.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/12/7.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCContactViewController.h"
#import "WCChatViewController.h"
#import "WCContactCell.h"
@interface WCContactViewController ()<NSFetchedResultsControllerDelegate>{
    
    NSFetchedResultsController *_resultsContr;
}

/**
 * 好友
 */
@property(strong,nonatomic)NSArray *friends;

@end

@implementation WCContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadUsers2];
    
}
#pragma mark 加载好友数据方法2
-(void)loadUsers2{
    //显示好友数据 （保存XMPPRoster.sqlite文件）
    
    //1.上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2.Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //过滤
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@",@"none"];
    request.predicate = pre;
    
    //设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //3.执行请求
    //3.1创建结果控制器
    // 数据库查询，如果数据很多，会放在子线程查询
    // 移动客户端的数据库里数据不会很多，所以很多数据库的查询操作都主线程
    _resultsContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    _resultsContr.delegate = self;
    NSError *err = nil;
    //3.2执行
    [_resultsContr performFetch:&err];
    
//    WCLog(@"%@",_resultsContr.fetchedObjects);
}
#pragma mark -结果控制器的代理
#pragma mark -数据库内容改变
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
//    WCLog(@"%@",[NSThread currentThread]);
    //刷新表格
    [self.tableView reloadData];
    
}

#pragma mark 加载好友数据方法1
-(void)loadUsers1{
    //显示好友数据 （保存XMPPRoster.sqlite文件）
    
    //1.上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2.Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //过滤
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@",@"none"];
    request.predicate = pre;
    
    //设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //3.执行请求
    NSError *error = nil;
    NSArray *friends = [rosterContext executeFetchRequest:request error:&error];

    self.friends = friends;
}
#pragma mark 返回多少行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.users.count;
    return _resultsContr.fetchedObjects.count;
//    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return _resultsContr.fetchedObjects.count;
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCContactCell *cell = [WCContactCell contactCellWithTableView:tableView];
    //获取对应的好友
//    XMPPUserCoreDataStorageObject *user = self.users[indexPath.row];
    XMPPUserCoreDataStorageObject *friend = _resultsContr.fetchedObjects[indexPath.row];
    //标识用户是否在线
    // 0:在线 1：离开 2：离线
//    WCLog(@"%@：在线状态%@",user.displayName,user.sectionNum);
    cell.mFriend = friend;
    // 1.通过KVO来监听用户状态的改变
    [friend addObserver:self forKeyPath:@"sectionNum" options:NSKeyValueObservingOptionNew context:nil];
    switch ([friend.sectionNum integerValue]) {
        case 0:
            cell.sectionNumLabel.text = @"在线";
            break;
        case 1:
            cell.sectionNumLabel.text = @"离开";
            break;
        case 2:
            cell.sectionNumLabel.text = @"离线";
            break;
        default:
            cell.sectionNumLabel.text = @"未知状态";
            break;
    }
    // 显示好友的头像
    if (friend.photo) { //默认的情况，不是程序一启动就有头像
        cell.headView.image = friend.photo;
    }else{
        //从服务器获取头像
        NSData *imgData = [[WCXMPPTool sharedWCXMPPTool].vCardAvatar photoDataForJID:friend.jid];
        cell.headView.image = [UIImage imageWithData:imgData];
    }

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    WCLog(@"====");
    [self.tableView reloadData];
}

#pragma mark - 删除好友
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   XMPPUserCoreDataStorageObject *friend = _resultsContr.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除好友
        [[WCXMPPTool sharedWCXMPPTool].roster removeUser:friend.jid];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPJID *friendJid = [_resultsContr.fetchedObjects[indexPath.row] jid];
    // 进入聊天控制器
    [self performSegueWithIdentifier:@"toChatVcSegue" sender:friendJid];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[WCChatViewController class]]) {
        WCChatViewController *chatVc = destVc;
        chatVc.friendJid = sender;
    }

}
@end
