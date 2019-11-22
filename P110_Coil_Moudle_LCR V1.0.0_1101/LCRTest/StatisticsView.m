//
//  StatisticsView.m
//  NationalTest
//
//  Created by Jason liang on 15-3-31.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "StatisticsView.h"

#define kClearButtonTag         501

@implementation StatisticsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self initStatisticsBox];
        [self initPassCountLabel];
        [self initPassCountEdit];
        [self initFailCountLabel];
        [self initFailCountEdit];
        [self initTotalCountLabel];
        [self initTotalCountEdit];
        [self initYieldLabel];
        [self initYieldEdit];
        [self initClearButton];
        
        [self initStatisticCounts];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)initStatisticsBox
{
    NSRect boxFrame = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    
    NSBox *box = [[NSBox alloc]initWithFrame:boxFrame];
    box.boxType = 1;
    box.borderWidth = 2.5;
    box.borderColor = [NSColor orangeColor];
    box.fillColor = [NSColor lightGrayColor];
    [box setTitle:@""];
    [box setTitleFont:[NSFont systemFontOfSize:12.0]];
    [self addSubview:box];
    //    [box release];
}

- (void)initPassCountLabel
{
    //设置Label的Frame
    NSRect labelFrame = NSMakeRect(20, 15, 60, 20);
    
    //创建一个运行时间标签
    NSTextField *label = [[NSTextField alloc]initWithFrame:labelFrame];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setStringValue:@"Pass:"];
    [label setFont:[NSFont systemFontOfSize:18.0]];
    [label setBordered:NO];
    [label setEditable:NO];
    [self addSubview:label];
    //    [label release];
}

- (void)initPassCountEdit
{
    //设置Edit的Frame
    NSRect editFrame = NSMakeRect(70, 10, 100, 25);
    
    //创建一个运行时间标签
    _passEdit = [[NSTextField alloc]initWithFrame:editFrame];
    //[edit setBackgroundColor:[NSColor clearColor]];
    [_passEdit setFont:[NSFont systemFontOfSize:18.0]];
    [_passEdit setStringValue:@"0"];
    [_passEdit setAlignment:NSCenterTextAlignment];
    [_passEdit setBordered:YES];
    [_passEdit setEditable:NO];
    [self addSubview:_passEdit];
    //    [edit release];
}

- (void)initFailCountLabel
{
    //设置Label的Frame
    NSRect labelFrame = NSMakeRect(190, 15, 60, 20);
    
    //创建一个运行时间标签
    NSTextField *label = [[NSTextField alloc]initWithFrame:labelFrame];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setStringValue:@"Fail:"];
    [label setFont:[NSFont systemFontOfSize:18.0]];
    [label setBordered:NO];
    [label setEditable:NO];
    [self addSubview:label];
    //    [label release];
}

- (void)initFailCountEdit
{
    //设置Edit的Frame
    NSRect editFrame = NSMakeRect(235, 10, 100, 25);
    
    //创建一个运行时间标签
    _failEdit = [[NSTextField alloc]initWithFrame:editFrame];
    //[edit setBackgroundColor:[NSColor clearColor]];
    [_failEdit setFont:[NSFont systemFontOfSize:18.0]];
    [_failEdit setStringValue:@"0"];
    [_failEdit setAlignment:NSCenterTextAlignment];
    [_failEdit setBordered:YES];
    [_failEdit setEditable:NO];
    [self addSubview:_failEdit];
    //    [edit release];
}

- (void)initTotalCountLabel
{
    //设置Label的Frame
    NSRect labelFrame = NSMakeRect(360, 15, 80, 20);
    
    //创建一个运行时间标签
    NSTextField *label = [[NSTextField alloc]initWithFrame:labelFrame];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setStringValue:@"Total:"];
    [label setFont:[NSFont systemFontOfSize:18.0]];
    [label setBordered:NO];
    [label setEditable:NO];
    [self addSubview:label];
    //    [label release];
}

- (void)initTotalCountEdit
{
    //设置Edit的Frame
    NSRect editFrame = NSMakeRect(420, 10, 100, 25);
    
    //创建一个运行时间标签
    _totalEdit = [[NSTextField alloc]initWithFrame:editFrame];
    //[edit setBackgroundColor:[NSColor clearColor]];
    [_totalEdit setFont:[NSFont systemFontOfSize:18.0]];
    [_totalEdit setStringValue:@"0"];
    [_totalEdit setAlignment:NSCenterTextAlignment];
    [_totalEdit setBordered:YES];
    [_totalEdit setEditable:NO];
    [self addSubview:_totalEdit];
    //    [edit release];
}

- (void)initYieldLabel
{
    //设置Label的Frame
    NSRect labelFrame = NSMakeRect(550, 15, 80, 20);
    
    //创建一个运行时间标签
    NSTextField *label = [[NSTextField alloc]initWithFrame:labelFrame];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setStringValue:@"Yield:"];
    [label setFont:[NSFont systemFontOfSize:18.0]];
    [label setBordered:NO];
    [label setEditable:NO];
    [self addSubview:label];
    //    [label release];
}

- (void)initYieldEdit
{
    //设置Edit的Frame
    NSRect editFrame = NSMakeRect(610, 10, 100, 25);
    
    //创建一个运行时间标签
    _yieldEdit = [[NSTextField alloc]initWithFrame:editFrame];
    //[edit setBackgroundColor:[NSColor clearColor]];
    [_yieldEdit setFont:[NSFont systemFontOfSize:18.0]];
    [_yieldEdit setStringValue:@"0"];
    [_yieldEdit setAlignment:NSCenterTextAlignment];
    [_yieldEdit setBordered:YES];
    [_yieldEdit setEditable:NO];
    [self addSubview:_yieldEdit];
    //    [edit release];
}

- (void)initClearButton
{
    //设置button的Frame
    NSRect btnFrame = NSMakeRect(720, 7, 80, 30);
    
    //创建一个设置按钮
    NSButton *btn = [[NSButton alloc]initWithFrame:btnFrame];
    [btn setBezelStyle:NSRegularSquareBezelStyle];
    [btn setTitle:@"Clear"];
    [btn setFont:[NSFont systemFontOfSize:16.0]];
    [btn setTag:kClearButtonTag];
    [btn setTarget:self];
    [btn setAction:@selector(buttonAction:)];
    [self addSubview:btn];
    //    [btn setEnabled:NO];
    //[btn release];
}

#pragma mark -
#pragma mark target action

- (void)buttonAction:(id)sender
{
    NSButton *button = (NSButton *)sender;
    
    if (button.tag == kClearButtonTag) {
        
        InputPasswordWindow *inputPassword;
        inputPassword = [[InputPasswordWindow alloc] initWithWindowNibName:@"InputPasswordWindow"];
        [inputPassword.window center];
        [NSApp runModalForWindow:[inputPassword window]];
        
        if (inputPassword.fConfirm) {
            [self clearStatistics];
        }
    }
}

#pragma mark -

- (void)initStatisticCounts
{
    NSString *strFail = nil;
    NSString *strPass = nil;
    NSString *strTotal = nil;
    NSString *strYield = nil;
    
    [self readFailCounts:&strFail PassCounts:&strPass TotalCounts:&strTotal Yield:&strYield];
    
    if ((strFail == nil) || (strPass == nil) || (strTotal == nil) || (strYield == nil)) {
        strFail = @"0";
        strPass = @"0";
        strTotal = @"0";
        strYield = @"0";
    }
    
    _failCount = [strFail intValue];
    _passCount = [strPass intValue];
    
    [self reflashStatistics];
}

- (void)clearStatistics
{
    _failCount = 0;
    _passCount = 0;
    
    [self reflashStatistics];
}

- (void)reflashStatistics
{
    NSString *strPass = [NSString stringWithFormat:@"%d", _passCount];
    [_passEdit setStringValue:strPass];
    
    NSString *strFail = [NSString stringWithFormat:@"%d", _failCount];
    [_failEdit setStringValue:strFail];
    
    _totalCount = _failCount + _passCount;
    
    NSString *strTotal = [NSString stringWithFormat:@"%d", _totalCount];
    [_totalEdit setStringValue:strTotal];
    
    if (_totalCount != 0) {
        _perYield = (float)_passCount*100/_totalCount;
    } else {
        _perYield = 0;
    }
    
    NSString *strYield = [NSString stringWithFormat:@"%.1f%%", _perYield];
    [_yieldEdit setStringValue:strYield];
    
    [self saveFailCounts:strFail PassCounts:strPass TotalCounts:strTotal Yield:strYield];
}

- (void)saveFailCounts:(NSString *)failCnt PassCounts:(NSString *)passCnt TotalCounts:(NSString *)totalCnt Yield:(NSString *)perYield
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
	if (standardUserDefaults) {
		[standardUserDefaults setObject:failCnt forKey:@"Fail"];
        [standardUserDefaults setObject:passCnt forKey:@"Pass"];
        [standardUserDefaults setObject:totalCnt forKey:@"Total"];
        [standardUserDefaults setObject:perYield forKey:@"Yield"];
		[standardUserDefaults synchronize];
	}
}

- (void)readFailCounts:(NSString **)failCnt PassCounts:(NSString **)passCnt TotalCounts:(NSString **)totalCnt Yield:(NSString **)perYield
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
	if (standardUserDefaults) {
		*failCnt =  [standardUserDefaults stringForKey:@"Fail"];
        *passCnt =  [standardUserDefaults stringForKey:@"Pass"];
        *totalCnt =  [standardUserDefaults stringForKey:@"Total"];
        *perYield =  [standardUserDefaults stringForKey:@"Yield"];
	}
}

@end
