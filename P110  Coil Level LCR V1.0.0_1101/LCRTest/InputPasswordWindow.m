//
//  InputPasswordWindow.m
//  CapMeasurement
//
//  Created by jason on 14-9-12.
//  Copyright (c) 2014年 Jason. All rights reserved.
//

#import "InputPasswordWindow.h"

#define kInputPWEditViewTag 200
#define kOKButtonTag        201
#define kCancelButtonTag    202
#define kConfirmButtonTag    203

@implementation InputPasswordWindow

- (BOOL)isFlipped
{
    return YES;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _fConfirm = NO;
    }
    return self;
}

//- (void)dealloc
//{
//    [self removeInputPWObserver];
//    [super dealloc];
//}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self initInputPWEdit];
    [self initCancelButton];
    [self initConfirmButton];
}

- (void)initInputPWEdit
{
    //设置Edit的Frame
    NSRect editFrame = NSMakeRect(100, 100, 300, 25);
    
    //创建一个运行时间标签
    NSSecureTextField *edit = [[NSSecureTextField alloc]initWithFrame:editFrame];
    [edit setFont:[NSFont systemFontOfSize:18.0]];
    [edit setAlignment:NSCenterTextAlignment];
    [edit setTag:kInputPWEditViewTag];
    [edit setBordered:YES];
    [edit setEditable:YES];
    
    //监测inutSN输入框
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidEndEditing:)
												 name:NSControlTextDidEndEditingNotification
											   object:edit];
    
    [edit setDelegate:self];
    [[self.window contentView] addSubview:edit];
    [edit becomeFirstResponder];//第一响应
//    [edit release];
}

- (void)initCancelButton
{
    //设置button的Frame
    NSRect btnFrame = NSMakeRect(240, 10, 80, 60);
    
    //创建一个设置按钮
    NSButton *btn = [[NSButton alloc]initWithFrame:btnFrame];
    [btn setBezelStyle:NSRoundedBezelStyle];
    [btn setTitle:@"Cancel"];
    [btn setFont:[NSFont systemFontOfSize:14.0]];
    [btn setTag:kCancelButtonTag];
    [btn setTarget:self];
    [btn setAction:@selector(buttonAction:)];
    [[self.window contentView] addSubview:btn];
    //    [btn release];
}

- (void)initConfirmButton
{
    //设置button的Frame
    NSRect btnFrame = NSMakeRect(340, 10, 80, 60);
    
    //创建一个设置按钮
    NSButton *btn = [[NSButton alloc]initWithFrame:btnFrame];
    [btn setBezelStyle:NSRoundedBezelStyle];
    [btn setTitle:@"OK"];
    [btn setFont:[NSFont systemFontOfSize:14.0]];
    [btn setTag:kConfirmButtonTag];
    [btn setTarget:self];
    [btn setAction:@selector(buttonAction:)];
    [[self.window contentView] addSubview:btn];
    //    [btn release];
}

#pragma mark -
- (void)buttonAction:(id)sender
{
    NSButton *button = (NSButton *)sender;
    int tag = (int)button.tag;
    
    if (tag == kCancelButtonTag) {
        _fConfirm = NO;
        [NSApp stopModal];
        [[self window] orderOut:nil];
    } else if (tag == kConfirmButtonTag) {
        NSSecureTextField *edit = (NSSecureTextField *)[[self.window contentView] viewWithTag:kInputPWEditViewTag];
        if ([[edit stringValue] isEqualToString:@"1234"]) {
            _fConfirm = YES;
            [NSApp stopModal];
            [[self window] orderOut:nil];
        } else {
            [edit setStringValue:@""];
        }
    }
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    NSSecureTextField *edit = (NSSecureTextField*)[notification object];
    
    if ([[edit stringValue] isEqualToString:@"1234"]) {
        _fConfirm = YES;
        [NSApp stopModal];
        [[self window] orderOut:nil];
    } else {
        [edit setStringValue:@""];
    }
}

//- (void)removeInputPWObserver
//{
//    NSTextField* inputPW = (NSTextField*)[self viewWithTag:kInputPWEditViewTag];
//
//	[[NSNotificationCenter defaultCenter] removeObserver:self
//													name:NSControlTextDidEndEditingNotification
//												  object:inputPW];
//}

- (BOOL)windowShouldClose:(id)sender
{
    [NSApp stopModalWithCode:1];
    [[self window] close];
    return TRUE;
    
}
@end
