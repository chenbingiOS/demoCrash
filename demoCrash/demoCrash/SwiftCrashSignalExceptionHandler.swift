//
//  SwiftCrashSignalExceptionHandler.swift
//  demoCrashSwift
//
//  Created by mtAdmin on 2021/6/17.
//

import Foundation

public typealias Completion = ()->Void;
public typealias CrashCallback = (String, Completion)->Void;

public var crashCallBack:CrashCallback?


final class SwiftCrashSignal {
    static func registerSignal() {
        registerSignalHanlder()
    }
    
    public static func setup(callBack:@escaping CrashCallback){
        crashCallBack = callBack;
        registerSignalHanlder();
    }
}

func signalHandler(signal: Int32) -> Void {
    var stackTrace = String();
    for symbol in Thread.callStackSymbols {
        stackTrace = stackTrace.appendingFormat("%@\r\n", symbol);
    }
    
    print(stackTrace)
        
    CrashTool.saveCrashLog(stackTrace, fileName: "SwiftCrash(singal)")
    
    unregisterSignalHandler();
    
    exit(signal)
    
}

func registerSignalHanlder()
{
    signal(SIGHUP, signalHandler) /* hangup */
    signal(SIGINT, signalHandler) /* interrupt */
    signal(SIGQUIT, signalHandler) /* quit */
    signal(SIGILL, signalHandler) /* illegal instruction (not reset when caught) */
    signal(SIGTRAP, signalHandler) /* trace trap (not reset when caught) */
    signal(SIGABRT, signalHandler) /* abort() */

    /* pollable event ([XSR] generated, not supported) */
    /* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
    signal(SIGIOT, signalHandler) /* compatibility */
    signal(SIGEMT, signalHandler) /* EMT instruction */
    /* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
    signal(SIGFPE, signalHandler) /* floating point exception */
    signal(SIGKILL, signalHandler) /* kill (cannot be caught or ignored) */
    signal(SIGBUS, signalHandler) /* bus error */
    signal(SIGSEGV, signalHandler) /* segmentation violation */
    signal(SIGSYS, signalHandler) /* bad argument to system call */
    signal(SIGPIPE, signalHandler) /* write on a pipe with no one to read it */
    signal(SIGALRM, signalHandler) /* alarm clock */
    signal(SIGTERM, signalHandler) /* software termination signal from kill */
    signal(SIGURG, signalHandler) /* urgent condition on IO channel */
    signal(SIGSTOP, signalHandler) /* sendable stop signal not from tty */
    signal(SIGTSTP, signalHandler) /* stop signal from tty */
    signal(SIGCONT, signalHandler) /* continue a stopped process */
    signal(SIGCHLD, signalHandler) /* to parent on child stop or exit */
    signal(SIGTTIN, signalHandler) /* to readers pgrp upon background tty read */
    signal(SIGTTOU, signalHandler) /* like TTIN for output if (tp->t_local&LTOSTOP) */

    signal(SIGIO, signalHandler) /* input/output possible signal */

    signal(SIGXCPU, signalHandler) /* exceeded CPU time limit */
    signal(SIGXFSZ, signalHandler) /* exceeded file size limit */
    signal(SIGVTALRM, signalHandler) /* virtual time alarm */
    signal(SIGPROF, signalHandler) /* profiling time alarm */

    signal(SIGWINCH, signalHandler) /* window size changes */
    signal(SIGINFO, signalHandler) /* information request */

    signal(SIGUSR1, signalHandler) /* user defined signal 1 */
    signal(SIGUSR2, signalHandler) /* user defined signal 2 */
}

func unregisterSignalHandler()
{
    signal(SIGHUP, SIG_DFL) /* hangup */
    signal(SIGINT, SIG_DFL) /* interrupt */
    signal(SIGQUIT, SIG_DFL) /* quit */
    signal(SIGILL, SIG_DFL) /* illegal instruction (not reset when caught) */
    signal(SIGTRAP, SIG_DFL) /* trace trap (not reset when caught) */
    signal(SIGABRT, SIG_DFL) /* abort() */

    /* pollable event ([XSR] generated, not supported) */
    /* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
    signal(SIGIOT, SIG_DFL) /* compatibility */
    signal(SIGEMT, SIG_DFL) /* EMT instruction */
    /* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
    signal(SIGFPE, SIG_DFL) /* floating point exception */
    signal(SIGKILL, SIG_DFL) /* kill (cannot be caught or ignored) */
    signal(SIGBUS, SIG_DFL) /* bus error */
    signal(SIGSEGV, SIG_DFL) /* segmentation violation */
    signal(SIGSYS, SIG_DFL) /* bad argument to system call */
    signal(SIGPIPE, SIG_DFL) /* write on a pipe with no one to read it */
    signal(SIGALRM, SIG_DFL) /* alarm clock */
    signal(SIGTERM, SIG_DFL) /* software termination signal from kill */
    signal(SIGURG, SIG_DFL) /* urgent condition on IO channel */
    signal(SIGSTOP, SIG_DFL) /* sendable stop signal not from tty */
    signal(SIGTSTP, SIG_DFL) /* stop signal from tty */
    signal(SIGCONT, SIG_DFL) /* continue a stopped process */
    signal(SIGCHLD, SIG_DFL) /* to parent on child stop or exit */
    signal(SIGTTIN, SIG_DFL) /* to readers pgrp upon background tty read */
    signal(SIGTTOU, SIG_DFL) /* like TTIN for output if (tp->t_local&LTOSTOP) */

    signal(SIGIO, SIG_DFL) /* input/output possible signal */

    signal(SIGXCPU, SIG_DFL) /* exceeded CPU time limit */
    signal(SIGXFSZ, SIG_DFL) /* exceeded file size limit */
    signal(SIGVTALRM, SIG_DFL) /* virtual time alarm */
    signal(SIGPROF, SIG_DFL) /* profiling time alarm */

    signal(SIGWINCH, SIG_DFL) /* window size changes */
    signal(SIGINFO, SIG_DFL) /* information request */

    signal(SIGUSR1, SIG_DFL) /* user defined signal 1 */
    signal(SIGUSR2, SIG_DFL) /* user defined signal 2 */
}
