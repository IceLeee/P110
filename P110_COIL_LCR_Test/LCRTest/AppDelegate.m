//
//  AppDelegate.m
//  LCRTest
//
//  Created by Hello_Apple on 16/7/13.
//  Copyright © 2016年 Luxshare-ICT. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    //create the main window
    NSRect rect = NSMakeRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    NSUInteger uiStyle = NSTitledWindowMask | NSClosableWindowMask;
    NSBackingStoreType backingStoreStyle = NSBackingStoreBuffered;
    
    _window = [[NSWindow alloc] initWithContentRect:rect styleMask:uiStyle backing:backingStoreStyle defer:NO];
    
    //create the main view
    _mainView = [[MainView alloc] initWithFrame:rect];
    [[_window contentView] addSubview:_mainView];
    
    //    [_window setLevel:1];
    [_window makeKeyAndOrderFront:self];
    [_window makeMainWindow];
    [_window center];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    if (_mainView) {
        [_mainView close];
    }
    
    return YES;
}

@end
