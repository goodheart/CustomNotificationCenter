//
//  SNHNotificationCenter.m
//  20160331NotificationCenterDemo
//
//  Created by majian on 16/3/31.
//  Copyright © 2016年 majian. All rights reserved.
//

#import "SNHNotificationCenter.h"

//发送通知的地方使用
const struct kSNHNotificationTypeKeys kSNHNotificationTypeKey =
{
    .logined = @"SNHNotificationTypeLogined",
    .logouted = @"SNHNotificationTypeLogouted",
    .loginFromOtherDevice =@"SNHNotificationTypeLoginFromOtherDevice",
    .locationChanged = @"SNHNotificationTypeLocationChanged",
};

@interface SNHNotificationCenter ()

@property (nonatomic,strong) NSMutableDictionary * observersContainerDictM;

@end

@implementation SNHNotificationCenter

#pragma mark - Public Method
/*!
 *  监听某种类型通知
 *  @param observer 坚挺着
 *  @param type     通知类型
 */
+ (void)addObserver:(id<SNHNotificationProtocol>)observer
listenToNotificationType:(SNHNotificationType)type {
    [[SNHNotificationCenter _defaultNotificationCenter] _addObserver:observer listenToNotificationType:type];
}

/*!
 *  监听所有SNHNotificationType类型的通知
 *  @param observer 监听者
 */
+ (void)addObserver:(id<SNHNotificationProtocol>)observer {
    SNHNotificationType notificationType = SNHNotificationTypeLogined |
    SNHNotificationTypeLogouted |
    SNHNotificationTypeLoginFromOtherDevice |
    SNHNotificationTypeLocationChanged;
    
    [self addObserver:observer
listenToNotificationType:notificationType];
}

/*!
 *  发送通知
 *  @param type     通知类型
 *  @param userInfo 通知时携带的自定义信息
 */
+ (void)postNotification:(NSString *)notificationType
            withUserInfo:(NSDictionary *)userInfo {
    [[SNHNotificationCenter _defaultNotificationCenter] _postNotification:notificationType withUserInfo:userInfo];
}

/*!
 *  发送通知,不需要携带自定义信息
 *  @param type 通知类型
 */
+ (void)postNotification:(NSString *)notificationType {
    [self postNotification:notificationType
              withUserInfo:nil];
}

#pragma mark - Private Method
static SNHNotificationCenter *_sharedNotificationCenter = nil;
+ (instancetype)_defaultNotificationCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedNotificationCenter = [SNHNotificationCenter new];
    });
    
    return _sharedNotificationCenter;
}

/*!
 *  私有发送通知方法
 */
- (void)_postNotification:(NSString *)notificationType
            withUserInfo:(NSDictionary *)userInfo {
        SNHNotificationType type = [self _parseStringToNotificationType:notificationType];
    
    if (type == SNHNotificationTypeUnKnow) {
        NSLog(@"SNHNotificationCenter 出现异常通知 发送同之处未传入正确的kSNHNotificationTypeKey");
        return;
    }
    
    NSArray * notificationTypeArrayI = [self _parseNotificationType:type];
    
    if (notificationTypeArrayI.count > 1) {
        NSLog(@"SNHNotificationCenter 不可以同时发送多个不同通知");
        return;
    }
    
    //get the key for the type
    NSNumber * typeNumber = notificationTypeArrayI.firstObject;
    //get the oberserContainers for the key
    NSHashTable * hashTable = self.observersContainerDictM[typeNumber];
    //get all obersers
    NSArray * allObserversArrayI = [hashTable allObjects];
    //if the count of obsevers is empty,that means no oberver right now,so remove the hashTable from observersContainers
    if (allObserversArrayI.count <= 0) {
        [self.observersContainerDictM removeObjectForKey:typeNumber];
        return;
    }
    
    //there is some observer,loop to notifice
    for (id<SNHNotificationProtocol> observer in allObserversArrayI) {
        if (nil != observer &&
            [observer respondsToSelector:@selector(didReceiveNotificationWithType:withUserInfo:)]) {
            [observer didReceiveNotificationWithType:type
                                        withUserInfo:userInfo];
        }
    }
}

/*!
 *  私有添加监听者方法
 */
- (void)_addObserver:(id<SNHNotificationProtocol>)observer
listenToNotificationType:(SNHNotificationType)type {
    
    if (nil == observer) {
        NSLog(@"SNHNotificationCenter  添加的观察者为 nl");
        return;
    }
    
    NSArray * typeArrayI = [self _parseNotificationType:type];
    for (NSNumber * typeNumer in typeArrayI) {
        //fetch hashTable container from observersContainer dictionary
        NSHashTable * observersContainer = self.observersContainerDictM[typeNumer];
        
        //if hashTable is empty ,create it and save it;
        if (nil == observersContainer) {
            observersContainer = [NSHashTable weakObjectsHashTable];
            [self.observersContainerDictM setObject:observersContainer
                                             forKey:typeNumer];
        }
        
        //save observer to container
        [observersContainer addObject:observer];
    }
}

- (NSArray<NSNumber *> *)_parseNotificationType:(SNHNotificationType)type {
    NSMutableArray<NSNumber *> * notificationTypeArrayM = [NSMutableArray new];
    
    if (type & SNHNotificationTypeLogined) {
        [notificationTypeArrayM addObject:@(SNHNotificationTypeLogined)];
    }
    
    if (type & SNHNotificationTypeLogouted) {
        [notificationTypeArrayM addObject:@(SNHNotificationTypeLogouted)];
    }
    
    if (type & SNHNotificationTypeLoginFromOtherDevice) {
        [notificationTypeArrayM addObject:@(SNHNotificationTypeLoginFromOtherDevice)];
    }
    
    if (type & SNHNotificationTypeLocationChanged) {
        [notificationTypeArrayM addObject:@(SNHNotificationTypeLocationChanged)];
    }
    
    return notificationTypeArrayM;
}

/*!
 *  将string转换成notificationType
 */
- (SNHNotificationType)_parseStringToNotificationType:(NSString *)type {
    SNHNotificationType notificationType = SNHNotificationTypeUnKnow;
    if (type == kSNHNotificationTypeKey.logined) {
        notificationType = SNHNotificationTypeLogined;
    } else if (type == kSNHNotificationTypeKey.logouted) {
        notificationType = SNHNotificationTypeLogouted;
    } else if (type == kSNHNotificationTypeKey.loginFromOtherDevice) {
        notificationType = SNHNotificationTypeLoginFromOtherDevice;
    } else if (type == kSNHNotificationTypeKey.locationChanged) {
        notificationType = SNHNotificationTypeLocationChanged;
    }
    
    return notificationType;
}

#pragma mark - Lazy Initializtion
- (NSMutableDictionary *)observersContainerDictM {
    if (!_observersContainerDictM) {
        _observersContainerDictM = [NSMutableDictionary new];
    }
    
    return _observersContainerDictM;
}
@end
