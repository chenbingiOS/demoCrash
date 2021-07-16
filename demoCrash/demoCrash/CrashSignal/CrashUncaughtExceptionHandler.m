//
//  CrashUncaughtExceptionHandler.m
//  MTEveApp
//
//  Created by mtAdmin on 2021/7/13.
//  Copyright © 2021 meitu. All rights reserved.
//

#import "CrashUncaughtExceptionHandler.h"
#import "CrashTool.h"

// 记录之前的崩溃回调函数
static NSUncaughtExceptionHandler *previousUncaughtExceptionHandler = NULL;

@implementation CrashUncaughtExceptionHandler

+ (void)registerHandler {
    // Backup original handler
    previousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    
    NSSetUncaughtExceptionHandler(&crashUncaughtHandler);
}

#pragma mark - Private

// 崩溃时的回调函数
static void crashUncaughtHandler(NSException *exception) {
     
    [CrashTool handlerUncaughException:exception];
    
    // 调用之前崩溃的回调函数
    if (previousUncaughtExceptionHandler) {
        previousUncaughtExceptionHandler(exception);
    }
    
    // 杀掉程序，这样可以防止同时抛出的SIGABRT被SignalException捕获
    kill(getpid(), SIGKILL);
}


@end
