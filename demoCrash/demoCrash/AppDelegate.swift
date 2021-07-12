//
//  AppDelegate.swift
//  demoCrash
//
//  Created by mtAdmin on 2021/6/13.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("applicationDidReceiveMemoryWarning")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
    }

    func applicationSignificantTimeChange(_ application: UIApplication) {
        print("applicationSignificantTimeChange")
    }    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        CrashSignalExceptionHandler.register()
        
//        DoraemonInstallCrashHandler()

//        KSCrashInstallCrashHandler()
        
//        SwiftCrashSignalHandler()
        
//        NSSetUncaughtExceptionHandler { (exception) in
//           let stack = exception.callStackReturnAddresses
//           print("Stack trace: \(stack)")
//
//            }
        
        return true
    }
    
    func SwiftCrashSignalHandler() {
//        SwiftCrashSignal.registerSignal()
        
//        SwiftCrashSignal.setup { (stackTrace, completion) in
//            print(stackTrace);
//            completion();
//        }
        
        signal(SIGABRT) {(a) in
                print(a)
            }

            signal(SIGABRT){(a) in
                print(a)
            }

            signal(SIGILL){(a) in
                print(a)
            }

            signal(SIGSEGV){(a) in
                print(a)
            }

            signal(SIGFPE){(a) in
                print(a)
            }

            signal(SIGBUS){(a) in
                print(a)
            }
            signal(SIGPIPE){(a) in
                print(a)
            }
    }
    
//    func DoraemonInstallCrashHandler() {
//        DoraemonCrashSignalExceptionHandler.register()
////        DoraemonCrashUncaughtExceptionHandler.register()
//    }
//
//    func KSCrashInstallCrashHandler() {
//        let installation = makeEmailInstallation()
//        installation.install()
//        KSCrash.sharedInstance()?.deleteBehaviorAfterSendAll = KSCDeleteOnSucess
//        installation.sendAllReports { (reports, completed, error) in
//            if completed {
//                print("Send \(String(describing: reports?.count)) reports")
//            } else {
//                print("Faild to send reports: \(String(describing: error))")
//            }
//        }
//    }
//
//    func makeEmailInstallation() -> KSCrashInstallation {
//        let emailAddress = "cb2@meitu.com"
//        let email = KSCrashInstallationEmail.sharedInstance()!
//        email.recipients = [emailAddress];
//        email.subject = "Crash Report";
//        email.message = "This is a crash report";
//        email.filenameFmt = "crash-report-%d.txt.gz";
//
//        email.addConditionalAlert(withTitle: "Crash Detected", message: "The app crashed last time it was launched. Send a crash report?", yesAnswer: "Sure!", noAnswer: "No thanks")
////        email.setReportStyle(KSCrashEmailReportStyleApple, useDefaultFilenameFormat: true)
//        email.reportStyle = KSCrashEmailReportStyleApple
//
//        return email
//    }

}

