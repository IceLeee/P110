//
//  RuntimeView.h
//  NationalTest
//
//  Created by Jason liang on 15-4-2.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RuntimeView : NSView {
    NSTextField *_timeField;
    NSTimer *_timer;
    float _iTimes;
}

- (void)startRuntime;
- (void)stopRuntime;

@end
