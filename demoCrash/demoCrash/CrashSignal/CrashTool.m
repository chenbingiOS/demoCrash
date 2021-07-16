//
//  CrashTool.m
//  DoraemonKit
//
//  Created by wenquan on 2018/11/22.
//

#import "CrashTool.h"
#import "CrashStateManager.h"

@interface CrashToolBridge : NSObject

@property (nonatomic, weak) id <CrashToolDelegate> delegate;

@end

@implementation CrashToolBridge

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end


static BOOL dismissed = NO;

@interface CrashTool ()

@property (nonatomic, strong) NSMutableArray *delegatesContainer;

@end

@implementation CrashTool

+ (instancetype)sharedInstance {
    static CrashTool *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self class] new];
    });
    return obj;
}

+ (void)handlerUncaughException:(NSException *)exception {
#if DEBUG
    NSArray * stackArray = [exception callStackSymbols]; // 异常的堆栈信息
    NSString * reason = [exception reason]; // 出现异常的原因
    NSString * name = [exception name]; // 异常名称
    NSString * exceptionInfo = [NSString stringWithFormat:@"========uncaughtException异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@", name, reason, [stackArray componentsJoinedByString:@"\n"]];
    // 保存崩溃日志到沙盒cache目录
    [CrashTool saveCrashLog:exceptionInfo fileName:@"Crash(Uncaught)"];
    [self handlerExceptionRunloop:exceptionInfo];
#endif
    // 记录此次崩溃
    [[CrashTool sharedInstance] startCallBack];
}

static NSString *signalName(int signal) {
    NSString *signalName;
    switch (signal) {
        case SIGABRT:
            signalName = @"SIGABRT";
            break;
        case SIGBUS:
            signalName = @"SIGBUS";
            break;
        case SIGFPE:
            signalName = @"SIGFPE";
            break;
        case SIGILL:
            signalName = @"SIGILL";
            break;
        case SIGPIPE:
            signalName = @"SIGPIPE";
            break;
        case SIGSEGV:
            signalName = @"SIGSEGV";
            break;
        case SIGSYS:
            signalName = @"SIGSYS";
            break;
        case SIGTRAP:
            signalName = @"SIGTRAP";
            break;
        default:
            break;
    }
    return signalName;
}

+ (void)handlerSignalException:(int)signal {
#if DEBUG
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Signal Exception:\n"];
    [mstr appendString:[NSString stringWithFormat:@"Signal %@ was raised.\n", signalName(signal)]];
    [mstr appendString:@"Call Stack:\n"];
    
    for (NSUInteger index = 1; index < NSThread.callStackSymbols.count; index++) {
        NSString *str = [NSThread.callStackSymbols objectAtIndex:index];
        [mstr appendString:[str stringByAppendingString:@"\n"]];
    }
    
    [mstr appendString:@"threadInfo:\n"];
    [mstr appendString:[[NSThread currentThread] description]];
    
    // 保存崩溃日志到沙盒cache目录
    NSString *exceptionInfo = [NSString stringWithString:mstr];

    [self saveCrashLog:exceptionInfo fileName:@"MTCrash(Signal)"];
    [self handlerExceptionRunloop:exceptionInfo];
#endif
    // 记录此次崩溃
    [[CrashTool sharedInstance] startCallBack];
}

+ (void)handlerExceptionRunloop:(NSString *)exceptionInfo {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFArrayRef allmodes  = CFRunLoopCopyAllModes(runloop);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Crash" message:exceptionInfo preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了确认按钮");
            dismissed = YES;
        }];
        [alert addAction:conform];
        UIViewController *topRootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
        // 在这里加一个这个样式的循环
        while (topRootViewController.presentedViewController) {
            // 这里固定写法
            topRootViewController = topRootViewController.presentedViewController;
        }
        // 然后再进行present操作
        [topRootViewController presentViewController:alert animated:YES completion:nil];
    });
    
    // 暂时活着
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allmodes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.0001, false);
        }
    }
    
    CFRelease(runloop);
}

+ (void)saveCrashLog:(NSString *)log fileName:(NSString *)fileName {
    if ([log isKindOfClass:[NSString class]] && (log.length > 0)) {
        // 获取当前年月日字符串
        NSDateFormatter *dateFormart = [[NSDateFormatter alloc]init];
        [dateFormart setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateFormart.timeZone = [NSTimeZone systemTimeZone];
        NSString *dateString = [dateFormart stringFromDate:[NSDate date]];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *crashDirectory = [self crashDirectory];
        if (crashDirectory && [manager fileExistsAtPath:crashDirectory]) {
            // 获取crash保存的路径
            NSString *crashPath = [crashDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Crash %@.txt", dateString]];
            if ([fileName isKindOfClass:[NSString class]] && (fileName.length > 0)) {
                crashPath = [crashDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %@.txt", fileName, dateString]];
            }
            
            BOOL isOK = [log writeToFile:crashPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"\n保存崩溃日志:%@\n目录\n%@\n", isOK ? @"成功": @"失败", crashPath);
        }
    }
}

+ (NSString *)crashDirectory {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *directory = [cachePath stringByAppendingPathComponent:@"Crash_State_Info"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:directory]) {
        [manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return directory;
}

- (void)startCallBack {
    for (CrashToolBridge *obj in self.delegatesContainer) {
        if ([obj.delegate respondsToSelector:@selector(crashToolCallBackState)]) {
            [obj.delegate crashToolCallBackState];
        }
    }
}

- (void)addDelegate:(id<CrashToolDelegate>)delegate {
    CrashToolBridge *bridge = [CrashToolBridge new];
    bridge.delegate = delegate;
    [self.delegatesContainer addObject:bridge];
}


- (NSMutableArray *)delegatesContainer {
    if (_delegatesContainer == nil) {
        _delegatesContainer = [[NSMutableArray alloc]init];
    }
    return _delegatesContainer;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
