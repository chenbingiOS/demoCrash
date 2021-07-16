//
//  CrashStateManager.m
//  demoCrash
//
//  Created by mtAdmin on 2021/7/9.
//

#import "CrashStateManager.h"
//#import <MTEve/MTEve-Swift.h>

static NSString * const KIsSkinState = @"KIsSkinState";
static NSString * const KIsCrashState = @"KIsCrashState";
static NSString * const KDateTimeDouble = @"KDateTimeDouble";

static NSString * const KCrashUserID = @"KCrashUserID";
static NSString * const KCrashPhoneNumber = @"KCrashPhoneNumber";

@implementation CrashStateManager

+ (void)setIsSkinState:(BOOL)isSkinState {
    [[NSUserDefaults standardUserDefaults] setBool:isSkinState forKey:KIsSkinState];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getIsSkinState {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KIsSkinState];
}

+ (void)setIsCrashState:(BOOL)isCrashState {
    [[NSUserDefaults standardUserDefaults] setBool:isCrashState forKey:KIsCrashState];
    
    double dateNow = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setDouble:dateNow forKey:KDateTimeDouble];
    
//    NSString *uid = [[MTEGlobalDataRecord shared] getUserId];
//    NSString *phoneNumber = [[MTEGlobalDataRecord shared] getPhoneNumber];
//    [[NSUserDefaults standardUserDefaults] setValue:uid forKey:KCrashUserID];
//    [[NSUserDefaults standardUserDefaults] setValue:phoneNumber forKey:KCrashPhoneNumber];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getIsCrashState {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KIsCrashState];
}

+ (BOOL)withinTwoMinutesCrash {
    double dateBefore = [[NSUserDefaults standardUserDefaults] boolForKey:KDateTimeDouble];
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

+ (NSString *)getCrashUserId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:KCrashUserID];
}

+ (NSString *)getCrashPhoneNumber {
    return [[NSUserDefaults standardUserDefaults] valueForKey:KCrashPhoneNumber];
}

@end
