//
//  CrashStateManager.h
//  demoCrash
//
//  Created by mtAdmin on 2021/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashStateManager : NSObject

/// 是否拍摄测肤中
+ (void)setIsSkinState:(BOOL)isSkinState;
+ (BOOL)getIsSkinState;

/// 是否崩溃
+ (void)setIsCrashState:(BOOL)isCrashState;
+ (BOOL)getIsCrashState;

/// 2 分钟之内重启
+ (BOOL)withinTwoMinutesCrash;

/// 获取崩溃的时候的用户 ID
+ (NSString *)getCrashUserId;

/// 获取崩溃的时候的用户电话号码
+ (NSString *)getCrashPhoneNumber;

@end

NS_ASSUME_NONNULL_END
