//
//  main.m
//  LCRTest
//
//  Created by Hello_Apple on 16/7/13.
//  Copyright © 2016年 Luxshare-ICT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    NSApplication *app = [NSApplication sharedApplication];
    id delegate = [[AppDelegate alloc] init];
    app.delegate = delegate;
    NSApplicationMain(argc, argv);
    return 0;
}
