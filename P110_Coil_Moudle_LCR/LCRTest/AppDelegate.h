//
//  AppDelegate.h
//  LCRTest
//
//  Created by Hello_Apple on 16/7/13.
//  Copyright © 2016年 Luxshare-ICT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CGDefine.h"
#import "MainView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly) NSWindow *window;
@property (retain) MainView *mainView;

@end

