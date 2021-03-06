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

static void CrashSignalHandler(int signal, siginfo_t * info, void * context) {
    
    [CrashTool handlerSignalException:signal];
    
    ClearSignalRigister();
    
    // ?????????????????????????????????
    previousSignalHandler(signal, info, context);
    
    kill(getpid(), SIGKILL);
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
    // SIG_DFL ????????????????????????
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
 
 ???????????????????????? ??????????????????????????????????????????????????????????????????POSIX
 SIGHUP??????1????????????????????????????????????????????????????????????????????????
 SIGINT??????2????????????????????????????????????????????????????????????????????????
 SIGQUIT??? 3????????????????????????????????????????????????????????????????????????
 SIGILL??????4????????????????????????????????????????????????????????????????????????
 SIGTRAP??? 5????????????????????????????????????????????????????????????????????????
 SIGABRT??? 6????????????????????????????????????????????????????????????????????????
 SIGEMT??????7?????????EMT ?????????????????????????????????????????????????????????
 SIGFPE??????8????????????????????????????????????????????????????????????????????????
 SIGKILL??? 9????????????????????????????????????????????????????????????????????????
 SIGBUS??????10?????? ???????????????????????????????????????????????????????????????
 SIGSEGV??? 11?????? ???????????????????????????????????????????????????????????????
 SIGSYS??????12?????? ??????call???????????????????????????????????????????????????
 SIGPIPE??? 13?????? ???????????????????????????????????????????????????????????????
 SIGALRM??? 14?????? ???????????????????????????????????????????????????????????????
 SIGTERM??? 15?????? ???????????????????????????????????????????????????????????????
 SIGURG??????16?????? IO????????????????????????????????????????????????????????????
 SIGSTOP??? 17?????? ???????????????????????????????????????????????????????????????
 SIGTSTP??? 18?????? ???????????????????????????????????????????????????????????????
 SIGCONT??? 19?????? ???????????????????????????????????????????????????????????????
 SIGCHLD??? 20?????? ???????????????????????????????????????????????????????????????
 SIGTTIN??? 21?????? ???????????????????????????????????????????????????????????????
 SIGTTOU??? 22?????? ???????????????????????????????????????????????????????????????
 SIGIO?????? 23?????? ??????I/O?????? ?????????????????????????????????????????????
 SIGXCPU??? 24?????? ??????CPU???????????????????????????????????????????????? ???
 SIGXFSZ??? 25?????? ???????????????????????????????????????????????????????????????
 SIGVTALRM 26?????? ???????????????????????????????????????????????????????????????
 SIGPROF??? 27?????? ???????????????????????????????????????????????????????????????
 SIGWINCH???28?????? ???????????????????????????????????????????????????????????????
 SIGINFO??? 29?????? ???????????????????????????????????????????????????????????????
 SIGUSR1 ???30?????? ????????????????????????????????????1????????????????????? ???
 SIGUSR2 ???31?????? ???????????????????????????????????????????????????????????????


 */
