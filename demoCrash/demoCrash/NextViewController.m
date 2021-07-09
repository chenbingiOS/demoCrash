//
//  NextViewController.m
//  demoCrash
//
//  Created by mtAdmin on 2021/6/16.
//

#import "NextViewController.h"

@interface NextViewController ()

@end

@implementation NextViewController

// pro hand -p true -s false SIGABRT

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)actionCrashMalloc:(id)sender {
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:1];
    NSInteger len = 203293514233333333;
    [data increaseLengthBy:len];
    
    /**
     demoCrash(5383,0x11427de00) malloc: can't allocate region
     :*** mach_vm_map(size=254116892791668736, flags: 100) failed (error code=3)
     demoCrash(5383,0x11427de00) malloc: *** set a breakpoint in malloc_error_break to debug
     demoCrash(5383,0x11427de00) malloc: can't allocate region
     :*** mach_vm_map(size=254116892791668736, flags: 100) failed (error code=3)
     demoCrash(5383,0x11427de00) malloc: *** set a breakpoint in malloc_error_break to debug
     */
}

- (IBAction)actionCrashArray:(id)sender {
    NSArray *ary = @[@"1", @"2"];
    NSLog(@"%@", ary[3]);
}

- (IBAction)actionCrashNotMethodString:(id)sender {
    // 不存在string的方法
    [self performSelector:@selector(string) withObject:nil afterDelay:2.0];
}

- (IBAction)actionCrashFree:(id)sender {
    // singal
    int list[2] = {1,2};
    int *p = list;
    //[奔溃位置]导致SIGABRT的错误，因为内存中根本就没有这个空间，哪来的free，就在栈中的对象而已
    free(p);
    p[1] = 5;
}


@end
