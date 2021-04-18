//
//  main.m
//  mach-vm-alloc
//
//  Created by Faisal Memon on 16/04/2021.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "mach_vm_example.h"
#import "mach_copy_on_write_example.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    vm_example();
    vm_copy_on_write_example();
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}


