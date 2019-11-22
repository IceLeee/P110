//
//  MessageTextView.m
//  NationalTest
//
//  Created by Jason liang on 15-4-21.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "MessageTextView.h"

@implementation MessageTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMessageTextViewController];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)initMessageTextViewController
{
    NSRect rectFrame = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    
    //创建一个scrollView容器
    _scrollViewContainer = [[NSScrollView alloc] initWithFrame:rectFrame];
    
    _textEdit = [[NSTextView alloc] initWithFrame:[[_scrollViewContainer contentView] bounds]];
    ////
//    _textEdit.backgroundColor = [NSColor blackColor];
//    _textEdit.textColor = [NSColor greenColor];
    [_textEdit setEditable:NO];
    
    [_scrollViewContainer setDocumentView:_textEdit];
	[self addSubview:_scrollViewContainer];
}


@end
