//
//  ViewController.m
//  20160331NotificationCenterDemo
//
//  Created by majian on 16/3/31.
//  Copyright © 2016年 majian. All rights reserved.
//

#import "ViewController.h"
#import "SNHNotificationCenter.h"

@interface ViewController ()<SNHNotificationProtocol>

@property (nonatomic,weak) IBOutlet UIButton * sendNotificationButton;
@property (nonatomic,weak) IBOutlet UIButton * sendNotificationWithUserInfoButton;
@end

#define kSNHNotificeType 0

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //注册监听多个类型通知
#if kSNHNotificeType
    [SNHNotificationCenter addObserver:self listenToNotificationType:SNHNotificationTypeLogined | SNHNotificationTypeLocationChanged | SNHNotificationTypeLoginFromOtherDevice | SNHNotificationTypeLogouted];
#else
    [SNHNotificationCenter addObserver:self];
#endif
    
}

#pragma mark -
- (void)didReceiveNotificationWithType:(SNHNotificationType)notificationType withUserInfo:(NSDictionary *)userInfo {
    switch (notificationType) {
            case SNHNotificationTypeUnKnow:
            break;
        case SNHNotificationTypeLogined: {
            NSLog(@"登录成功 %@",userInfo);
            break;
        }
        case SNHNotificationTypeLogouted: {
            NSLog(@"退出登录成功 %@",userInfo);
            break;
        }
        case SNHNotificationTypeLoginFromOtherDevice: {
            NSLog(@"账号在其他地方登录 %@",userInfo);
            break;
        }
        case SNHNotificationTypeLocationChanged: {
            NSLog(@"换团成功 %@",userInfo);
            break;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //换团了
    [SNHNotificationCenter postNotification:kSNHNotificationTypeKey.locationChanged];
}

- (IBAction)sendNotiAction:(id)sender {
    //账号在其他设备登录
    [SNHNotificationCenter postNotification:kSNHNotificationTypeKey.loginFromOtherDevice];
}

- (IBAction)sendNotifiWithUserInfoAction:(id)sender {
    //登录成功  带userInfo
    [SNHNotificationCenter postNotification:kSNHNotificationTypeKey.logined withUserInfo:@{@"hahha":@"fasdfasdf"}];
}

- (IBAction)loginoutAction:(id)sender {
    [SNHNotificationCenter postNotification:kSNHNotificationTypeKey.logouted];
}

@end
