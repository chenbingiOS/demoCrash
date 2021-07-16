//
//  CrashUncaughtExceptionHandler.h
//  MTEveApp
//
//  Created by mtAdmin on 2021/7/13.
//  Copyright © 2021 meitu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashUncaughtExceptionHandler : NSObject

+ (void)registerHandler;

@end

NS_ASSUME_NONNULL_END
