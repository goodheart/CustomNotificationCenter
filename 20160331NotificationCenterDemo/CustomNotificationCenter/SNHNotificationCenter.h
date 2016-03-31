/*!SNHNotificationCenter.h

@abstract <#abstract#>

@author Created by majian on 16/3/31.

@version <#version#> 16/3/31 Creation

Copyright © 2016年 majian. All rights reserved.

 github address : https://github.com/goodheart/CustomNotificationCenter
*/

#import <Foundation/Foundation.h>

extern const struct kSNHNotificationTypeKeys {
    __unsafe_unretained NSString * logined;
    __unsafe_unretained NSString * logouted;
    __unsafe_unretained NSString * loginFromOtherDevice;
    __unsafe_unretained NSString * locationChanged;
}kSNHNotificationTypeKeys;

//接收通知的地方使用
typedef NS_ENUM(NSUInteger,SNHNotificationType) {
    SNHNotificationTypeUnKnow = 1 << 0, //异常
    SNHNotificationTypeLogined = 1 << 1, //登陆
    SNHNotificationTypeLogouted = 1 << 2 , //退出登陆
    SNHNotificationTypeLoginFromOtherDevice = 1 << 3, //账号在其他地方登陆
    SNHNotificationTypeLocationChanged = 1 << 4, //用户切换了分团
};

extern const struct kSNHNotificationTypeKeys kSNHNotificationTypeKey;

@protocol SNHNotificationProtocol <NSObject>

/*!
 *  接收到了通知回调
 *  @param notificationType 通知类型
 *  @param userInfo         自定义的信息,只起到传递作用
 */
- (void)didReceiveNotificationWithType:(SNHNotificationType)notificationType withUserInfo:(NSDictionary *)userInfo;

@end

/*!

@class SNHNotificationCenter

@abstract 自定义通知中心 1、隔离系统通知中心，限制通知类型，防止项目中自定义通知乱飞 2、统一通知调用方法 3、对observer弱引用，简化接收通知流程，防止人为引发的异常。

*/
@interface SNHNotificationCenter : NSObject

/*!
 *  监听某种类型通知
 *  @param observer 坚挺着
 *  @param type     通知类型
 */
+ (void)addObserver:(id<SNHNotificationProtocol>)observer
listenToNotificationType:(SNHNotificationType)type;

/*!
 *  监听所有SNHNotificationType类型的通知
 *  @param observer 监听者
 */
+ (void)addObserver:(id<SNHNotificationProtocol>)observer;

/*!
 *  发送通知
 *  @param type     通知类型
 *  @param userInfo 通知时携带的自定义信息
 */
+ (void)postNotification:(NSString *)notificationType
            withUserInfo:(NSDictionary *)userInfo;
/*!
 *  发送通知,不需要携带自定义信息
 *  @param type 通知类型
 */
+ (void)postNotification:(NSString *)notificationType;

@end










