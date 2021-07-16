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

- (void)crashToolCallBackState;

@end


@interface CrashTool : NSObject

+ (instancetype)sharedInstance;
- (void)addDelegate:(id<CrashToolDelegate>)delegate;

+ (void)handlerUncaughException:(NSException *)exception;
+ (void)handlerSignalException:(int)signal;

@end

NS_ASSUME_NONNULL_END
