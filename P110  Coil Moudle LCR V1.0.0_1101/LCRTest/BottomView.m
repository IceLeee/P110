//
//  BottomView.m
//  ReadSN
//
//  Created by Wade on 16/1/15.
//  Copyright © 2016年 Luxshare-ICT. All rights reserved.
//

#import "BottomView.h"

@implementation BottomView

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
        //[self initInfoFile];
        [self initbottombg];
        [self initCopyrightLabel];
        //NSLog(@"Copyright : %@",_copyright);
    }
    return self;
}

//question 1
- (void)initInfoFile{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    _copyright = [dict objectForKey:@"Copyright (human-readable)"];
    
}

//背景
- (void)initbottombg{
    NSRect frame =NSMakeRect(0, 0,self.frame.size.width, self.frame.size.height);
    NSImageView *bgImage = [[NSImageView alloc] initWithFrame:frame];
    [bgImage setImage:[NSImage imageNamed:@"titlebg.jpg"]];
    [bgImage setImageScaling:NSImageScaleAxesIndependently];
    [self addSubview:bgImage];
}

//大标题
- (void)initCopyrightLabel{
    NSRect frame = NSMakeRect(self.frame.size.width / 2 - 300, 5, 600, self.frame.size.height - 10);
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.backgroundColor = [NSColor clearColor];
    label.alignment = NSCenterTextAlignment;
    label.stringValue = @"Copyright © 2017 Luxshare-ICT. All rights reserved.";
    label.font = [NSFont systemFontOfSize:14.0];
    label.textColor = [NSColor whiteColor];
    label.bordered = 0;
    label.editable = 0;

    [self addSubview:label];
}


@end
