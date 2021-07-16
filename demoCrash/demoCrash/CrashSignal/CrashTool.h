//
//  CrashTool.h
//  DoraemonKit
//
//  Created by wenquan on 2018/11/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CrashToolDelegate <NSObject>

/// 告诉外部发生崩溃
- (void)crashToolCallBackState;

@end


@interface CrashTool : NSObject

/// 单例对象
+ (instancetype)sharedInstance;

/// 实现多代理
/// @param delegate 实现代理方法的类
- (void)addDelegate:(id<CrashToolDelegate>)delegate;

/// 注册崩溃监听工具
+ (void)registerCrashHandler;

/// OC 崩溃类型
/// 系统崩溃回调工具类处理方法
/// @param exception OC 异常对象
+ (void)handlerUncaughException:(NSException *)exception;

/// Signal 崩溃类型
/// 系统崩溃回调工具类处理方法
/// @param signal 崩溃信号编号
+ (void)handlerSignalException:(int)signal;

@end

NS_ASSUME_NONNULL_END
