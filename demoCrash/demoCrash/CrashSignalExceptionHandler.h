//
//  CrashSignalExceptionHandler.h
//  DoraemonKit
//
//  Created by wenquan on 2018/11/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashSignalExceptionHandler : NSObject

+ (void)registerHandler;

@end

NS_ASSUME_NONNULL_END
