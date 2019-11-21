//
//  StatisticsView.h
//  NationalTest
//
//  Created by Jason liang on 15-3-31.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InputPasswordWindow.h"

@interface StatisticsView : NSView
{
    int _passCount;
    int _failCount;
    int _totalCount;
    float _perYield;
    
    NSTextField *_passEdit;
    NSTextField *_failEdit;
    NSTextField *_totalEdit;
    NSTextField *_yieldEdit;
}

@property (assign) int passCount;
@property (assign) int failCount;

- (void)reflashStatistics;
- (void)clearStatistics;

@end
