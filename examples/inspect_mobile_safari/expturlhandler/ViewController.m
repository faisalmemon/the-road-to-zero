//
//  ViewController.m
//  expturlhandler
//
//  Created by Faisal Memon on 07/11/2021.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"x-web-search://?toast"]
                                       options:@{}  completionHandler:^(BOOL success) {
        NSLog(@"status %ld", (long)success);
    }];
}


@end
