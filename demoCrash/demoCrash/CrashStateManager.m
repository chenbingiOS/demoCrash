//
//  CrashStateManager.m
//  demoCrash
//
//  Created by mtAdmin on 2021/7/9.
//

#import "CrashStateManager.h"

@implementation CrashStateManager

+ (void)setIsCrashState:(BOOL)isCrashState {
    [[NSUserDefaults standardUserDefaults] setBool:isCrashState forKey:@"KIsCrashState"];
    double dateNow = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setDouble:dateNow forKey:@"kDateDouble"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getIsCrashState {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"KIsCrashState"];
}

+ (BOOL)withinTwoMinutesCrash {
    double dateBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDateDouble"];
    double dateNow = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    if (dateBefore - dateNow < 120) {
        NSLog(@"崩溃时间[%@]",@(dateBefore));
        NSLog(@"启动时间[%@]",@(dateNow));
        NSLog(@"产生崩溃，并且在 2 分钟之内重启，需要进入重新拍照分析页面");
        return YES;
    } else {
        NSLog(@"产生崩溃，超过 2 分钟");
        return NO;
    }
}



@end
