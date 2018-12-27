//
//  ViewController.m
//  MbedtlsForIOS
//
//  Created by GuHaijun on 2018/12/25.
//  Copyright © 2018 GuHaijun. All rights reserved.
//

#import "ViewController.h"
#import "selftest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    selftest_main(0, 0);
    char *argv = NULL;
    selftest_main( 0, &argv );
}


@end
