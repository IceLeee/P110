//
//  TitleView.m
//  ApplicationTest
//
//  Created by Wade on 15/12/12.
//  Copyright (c) 2015年 Luxshare-ICT. All rights reserved.
//

#import "TitleView.h"

@implementation TitleView

- (BOOL)isFlipped{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (id)initWithFrame:(NSRect)frameRect{
    
    if (self = [super initWithFrame:frameRect]) {
        [self initTestConfigFile];
        [self initTitlebg];
        [self initTitleLogo];
        [self initTitleLabel];
        [self initSWVLabel];
//        [self initCBVLabel];
//        [self initCBVEdit];
//        [self initPPBVLabel];
//        [self initPPBVEdit];
    }
       return self;
}

//背景
- (void)initTitlebg{
    NSRect frame =NSMakeRect(0, 0,self.frame.size.width, self.frame.size.height);
    NSImageView *bgImage = [[NSImageView alloc] initWithFrame:frame];
    [bgImage setImage:[NSImage imageNamed:@"titlebg.jpg"]];
    [bgImage setImageScaling:NSImageScaleAxesIndependently];
    [self addSubview:bgImage];
}

//logo
- (void)initTitleLogo{
    NSRect frame =NSMakeRect(0, 7,200, self.frame.size.height - 7);
    NSImageView *logoImage = [[NSImageView alloc] initWithFrame:frame];
    [logoImage setImage:[NSImage imageNamed:@"logo.jpg"]];
    [logoImage setImageScaling:1];
    [self addSubview:logoImage];
}

- (void)initTestConfigFile{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestConfig" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    _strSWName = [dict objectForKey:@"SW_Name"];
    _strSWVersion = [dict objectForKey:@"SW_Version"];
}

//大标题
- (void)initTitleLabel{
    NSRect frame = NSMakeRect(self.frame.size.width / 2 - 190, 9, 380, self.frame.size.height - 10);
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.backgroundColor = [NSColor clearColor];
    label.alignment = NSCenterTextAlignment;
    label.stringValue = _strSWName;
    label.font = [NSFont systemFontOfSize:45.0];
    label.textColor = [NSColor orangeColor];
    label.bordered = 0;
    label.editable = 0;
    [self addSubview:label];
}

//小标题
- (void)initSWVLabel
{
    NSRect frame = NSMakeRect(self.frame.size.width / 2 + 285 , 35, 200, 25);
    NSTextField *label = [[NSTextField alloc]initWithFrame:frame];
    label.backgroundColor = [NSColor clearColor];
    label.alignment = NSLeftTextAlignment;
    label.stringValue = [NSString stringWithFormat:@"Version:%@",_strSWVersion];
    label.font = [NSFont systemFontOfSize:17.0];
    label.textColor = [NSColor whiteColor];
    label.bordered = 0;
    label.editable = 0;
    [self addSubview:label];
}

- (void)initCBVLabel
{
    NSRect frame = NSMakeRect(self.frame.size.width / 2 + 240 , 46, 200, 25);
    NSTextField *label = [[NSTextField alloc]initWithFrame:frame];
    label.backgroundColor = [NSColor clearColor];
    label.alignment = NSLeftTextAlignment;
    label.stringValue = [NSString stringWithFormat:@"C  B_Version:"];
    label.font = [NSFont systemFontOfSize:21.0];
    label.textColor = [NSColor whiteColor];
    label.bordered = 0;
    label.editable = 0;
    [self addSubview:label];
}

- (void)initCBVEdit {
    _txfCBVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(self.frame.size.width / 2 + 362,46,100,25)];
    _txfCBVersion.font = [NSFont systemFontOfSize:21.0];
    _txfCBVersion.backgroundColor = [NSColor clearColor];
    _txfCBVersion.stringValue = @"V1.0.0";
    _txfCBVersion.textColor = [NSColor whiteColor];
    _txfCBVersion.alignment = NSLeftTextAlignment;
    _txfCBVersion.bordered = 0;
    _txfCBVersion.editable = 0;
    [self addSubview:_txfCBVersion];
}

- (void)initPPBVLabel
{
    NSRect frame = NSMakeRect(self.frame.size.width / 2 + 135 , 45, 150, 25);
    NSTextField *label = [[NSTextField alloc]initWithFrame:frame];
    label.backgroundColor = [NSColor clearColor];
    label.alignment = NSLeftTextAlignment;
    label.stringValue = [NSString stringWithFormat:@"PPB_Version:V"];
    label.font = [NSFont systemFontOfSize:17.0];
    label.textColor = [NSColor whiteColor];
    label.bordered = 0;
    label.editable = 0;
    [self addSubview:label];
}

- (void)initPPBVEdit {
    _txfPPBVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(self.frame.size.width / 2 + 250,45,100,25)];
    _txfPPBVersion.font = [NSFont systemFontOfSize:17.0];
    _txfPPBVersion.backgroundColor = [NSColor clearColor];
    _txfPPBVersion.textColor = [NSColor whiteColor];
    _txfPPBVersion.alignment = NSLeftTextAlignment;
    _txfPPBVersion.bordered = 0;
    _txfPPBVersion.editable = 0;
    [self addSubview:_txfPPBVersion];
}

@end
