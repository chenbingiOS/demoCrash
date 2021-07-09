//
//  CrashSignalExceptionHandler.m
//  Kit
//
//  Created by wenquan on 2018/11/22.
//

#import "CrashSignalExceptionHandler.h"

#import <execinfo.h>

#import "CrashTool.h"

typedef void (*SignalHandler)(int signal, siginfo_t *info, void *context);

static SignalHandler previousABRTSignalHandler = NULL;
static SignalHandler previousBUSSignalHandler  = NULL;
static SignalHandler previousFPESignalHandler  = NULL;
static SignalHandler previousILLSignalHandler  = NULL;
static SignalHandler previousPIPESignalHandler = NULL;
static SignalHandler previousSEGVSignalHandler = NULL;
static SignalHandler previousSYSSignalHandler  = NULL;
static SignalHandler previousTRAPSignalHandler = NULL;

static BOOL dismissed = NO;

@implementation CrashSignalExceptionHandler

#pragma mark - Register

+ (void)registerHandler {
    // Backup original handler
    [self backupOriginalHandler];
    
    [self signalRegister];
}

+ (void)backupOriginalHandler {
    struct sigaction old_action_abrt;
    sigaction(SIGABRT, NULL, &old_action_abrt);
    if (old_action_abrt.sa_sigaction) {
        previousABRTSignalHandler = old_action_abrt.sa_sigaction;
    }
    
    struct sigaction old_action_bus;
    sigaction(SIGBUS, NULL, &old_action_bus);
    if (old_action_bus.sa_sigaction) {
        previousBUSSignalHandler = old_action_bus.sa_sigaction;
    }
    
    struct sigaction old_action_fpe;
    sigaction(SIGFPE, NULL, &old_action_fpe);
    if (old_action_fpe.sa_sigaction) {
        previousFPESignalHandler = old_action_fpe.sa_sigaction;
    }
    
    struct sigaction old_action_ill;
    sigaction(SIGILL, NULL, &old_action_ill);
    if (old_action_ill.sa_sigaction) {
        previousILLSignalHandler = old_action_ill.sa_sigaction;
    }
    
    struct sigaction old_action_pipe;
    sigaction(SIGPIPE, NULL, &old_action_pipe);
    if (old_action_pipe.sa_sigaction) {
        previousPIPESignalHandler = old_action_pipe.sa_sigaction;
    }
    
    struct sigaction old_action_segv;
    sigaction(SIGSEGV, NULL, &old_action_segv);
    if (old_action_segv.sa_sigaction) {
        previousSEGVSignalHandler = old_action_segv.sa_sigaction;
    }
    
    struct sigaction old_action_sys;
    sigaction(SIGSYS, NULL, &old_action_sys);
    if (old_action_sys.sa_sigaction) {
        previousSYSSignalHandler = old_action_sys.sa_sigaction;
    }
    
    struct sigaction old_action_trap;
    sigaction(SIGTRAP, NULL, &old_action_trap);
    if (old_action_trap.sa_sigaction) {
        previousTRAPSignalHandler = old_action_trap.sa_sigaction;
    }
}

+ (void)signalRegister {
    CrashSignalRegister(SIGABRT);
    CrashSignalRegister(SIGBUS);
    CrashSignalRegister(SIGFPE);
    CrashSignalRegister(SIGILL);
    CrashSignalRegister(SIGPIPE);
    CrashSignalRegister(SIGSEGV);
    CrashSignalRegister(SIGSYS);
    CrashSignalRegister(SIGTRAP);
}

#pragma mark - Private

#pragma mark Register Signal

static void CrashSignalRegister(int signal) {
    struct sigaction action;
    action.sa_sigaction = CrashSignalHandler;
    action.sa_flags = SA_NODEFER | SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    sigaction(signal, &action, 0);
}

#pragma mark SignalCrash Handler

static void CrashSignalHandler(int signal, siginfo_t* info, void* context) {
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Signal Exception:\n"];
    [mstr appendString:[NSString stringWithFormat:@"Signal %@ was raised.\n", signalName(signal)]];
    [mstr appendString:@"Call Stack:\n"];
    
    //    void* callstack[128];
    //    int i, frames = backtrace(callstack, 128);
    //    char** strs = backtrace_symbols(callstack, frames);
    //    for (i = 0; i <frames; ++i) {
    //        [mstr appendFormat:@"%s\n", strs[i]];
    //    }
    
    // 这里过滤掉第一行日志
    // 因为注册了信号崩溃回调方法，系统会来调用，将记录在调用堆栈上，因此此行日志需要过滤掉
    for (NSUInteger index = 1; index < NSThread.callStackSymbols.count; index++) {
        NSString *str = [NSThread.callStackSymbols objectAtIndex:index];
        [mstr appendString:[str stringByAppendingString:@"\n"]];
    }
    
    [mstr appendString:@"threadInfo:\n"];
    [mstr appendString:[[NSThread currentThread] description]];
    
    // 保存崩溃日志到沙盒cache目录
    NSString *path = [NSString stringWithString:mstr];
    [CrashTool saveCrashLog:path fileName:@"Crash(Signal)"];
        
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFArrayRef allmodes  = CFRunLoopCopyAllModes(runloop);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Crash(Signal)" message:path preferredStyle:UIAlertControllerStyleAlert];
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
    
    // 起死回生
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allmodes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.0001, false);
        }
    }
    
    CFRelease(runloop);
    
    ClearSignalRigister();
    
    // 调用之前崩溃的回调函数
    previousSignalHandler(signal, info, context);
    
    kill(getpid(), SIGKILL);
}

#pragma mark Signal To Name

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

#pragma mark Previous Signal

static void previousSignalHandler(int signal, siginfo_t *info, void *context) {
    SignalHandler previousSignalHandler = NULL;
    switch (signal) {
        case SIGABRT:
            previousSignalHandler = previousABRTSignalHandler;
            break;
        case SIGBUS:
            previousSignalHandler = previousBUSSignalHandler;
            break;
        case SIGFPE:
            previousSignalHandler = previousFPESignalHandler;
            break;
        case SIGILL:
            previousSignalHandler = previousILLSignalHandler;
            break;
        case SIGPIPE:
            previousSignalHandler = previousPIPESignalHandler;
            break;
        case SIGSEGV:
            previousSignalHandler = previousSEGVSignalHandler;
            break;
        case SIGSYS:
            previousSignalHandler = previousSYSSignalHandler;
            break;
        case SIGTRAP:
            previousSignalHandler = previousTRAPSignalHandler;
            break;
        default:
            break;
    }
    
    if (previousSignalHandler) {
        previousSignalHandler(signal, info, context);
    }
}

#pragma mark Clear

static void ClearSignalRigister() {
    // SIG_DFL 默认信号处理程序
    signal(SIGSEGV,SIG_DFL);
    signal(SIGFPE,SIG_DFL);
    signal(SIGBUS,SIG_DFL);
    signal(SIGTRAP,SIG_DFL);
    signal(SIGABRT,SIG_DFL);
    signal(SIGILL,SIG_DFL);
    signal(SIGPIPE,SIG_DFL);
    signal(SIGSYS,SIG_DFL);
}
@end

/**
 
 符号名　　信号值 描述　　　　　　　　　　　　　　　　是否符合POSIX
 SIGHUP　　1　　　在控制终端上检测到挂断或控制线程死亡　　是
 SIGINT　　2　　　交互注意信号　　　　　　　　　　　　　　是
 SIGQUIT　 3　　　交互中止信号　　　　　　　　　　　　　　是
 SIGILL　　4　　　检测到非法硬件的指令　　　　　　　　　　是
 SIGTRAP　 5　　　从陷阱中回朔　　　　　　　　　　　　　　否
 SIGABRT　 6　　　异常终止信号　　　　　　　　　　　　　　是
 SIGEMT　　7　　　EMT 指令　　　　　　　　　　　　　　　　否
 SIGFPE　　8　　　不正确的算术操作信号　　　　　　　　　　是
 SIGKILL　 9　　　终止信号　　　　　　　　　　　　　　　　是
 SIGBUS　　10　　 总线错误　　　　　　　　　　　　　　　　否
 SIGSEGV　 11　　 检测到非法的内存调用　　　　　　　　　　是
 SIGSYS　　12　　 系统call的错误参数　　　　　　　　　　　否
 SIGPIPE　 13　　 在无读者的管道上写　　　　　　　　　　　是
 SIGALRM　 14　　 报时信号　　　　　　　　　　　　　　　　是
 SIGTERM　 15　　 终止信号　　　　　　　　　　　　　　　　是
 SIGURG　　16　　 IO信道紧急信号　　　　　　　　　　　　　否
 SIGSTOP　 17　　 暂停信号　　　　　　　　　　　　　　　　是
 SIGTSTP　 18　　 交互暂停信号　　　　　　　　　　　　　　是
 SIGCONT　 19　　 如果暂停则继续　　　　　　　　　　　　　是
 SIGCHLD　 20　　 子线程终止或暂停　　　　　　　　　　　　是
 SIGTTIN　 21　　 后台线程组一成员试图从控制终端上读出　　是
 SIGTTOU　 22　　 后台线程组的成员试图写到控制终端上　　　是
 SIGIO　　 23　　 允许I/O信号 　　　　　　　　　　　　　　否
 SIGXCPU　 24　　 超出CPU时限　　　　　　　　　　　　　　 否
 SIGXFSZ　 25　　 超出文件大小限制　　　　　　　　　　　　否
 SIGVTALRM 26　　 虚时间警报器　　　　　　　　　　　　　　否
 SIGPROF　 27　　 侧面时间警报器　　　　　　　　　　　　　否
 SIGWINCH　28　　 窗口大小的更改　　　　　　　　　　　　　否
 SIGINFO　 29　　 消息请求　　　　　　　　　　　　　　　　否
 SIGUSR1 　30　　 保留作为用户自定义的信号1　　　　　　　 是
 SIGUSR2 　31　　 保留作为用户自定义的信号　　　　　　　　是


 */
