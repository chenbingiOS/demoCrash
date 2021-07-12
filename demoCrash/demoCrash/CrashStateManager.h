//
//  CrashStateManager.h
//  demoCrash
//
//  Created by mtAdmin on 2021/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashStateManager : NSObject

+ (void)setIsCrashState:(BOOL)isCrashState;
+ (BOOL)getIsCrashState;
+ (BOOL)withinTwoMinutesCrash;

@end

NS_ASSUME_NONNULL_END
