//
//  ViewController.swift
//  demoCrash
//
//  Created by mtAdmin on 2021/6/13.
//

import UIKit

class ViewController: UIViewController {

    // pro hand -p true -s false SIGABRT
    // pro hand -p true -s false SIGTRAP/EXC_BREAKPOINT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    var a = 0
    
    @IBAction func actionCrashArray(_ sender: Any) {
//        let ary = ["1","2"]
//        print(ary[2])
        
//        print([0][1])
        
        _ = 1/a
    }

    @IBAction func actionCrashMalloc(_ sender: Any) {
        let a:Int? = nil;
        print(a!);
    }
}


