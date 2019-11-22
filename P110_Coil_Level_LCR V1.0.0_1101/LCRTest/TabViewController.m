//
//  TabViewController.m
//  NationalTest
//
//  Created by Jason liang on 15-4-2.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "TabViewController.h"
#import "CGDefine.h"

@implementation TabViewController

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTabViewController];
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)initTabViewController
{
    NSRect tabFrame = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    
    //设置TableViews
    _tableViews = [[NSView alloc] initWithFrame:tabFrame];
    
    _tableView1 = [[TableViewController alloc] initWithFrame:tabFrame];
    //_tableView2 = [[TableViewController alloc] initWithFrame:tabFrame];
    
    NSRect table1Frame = NSMakeRect(TABLEVIEW1_X, TABLEVIEW1_Y, TABLEVIEW1_WIDTH, TABLEVIEW1_HEIGHT);
    //NSRect table2Frame = NSMakeRect(TABLEVIEW2_X, TABLEVIEW2_Y, TABLEVIEW2_WIDTH, TABLEVIEW2_HEIGHT);
    
    [_tableView1.scrollViewContainer setFrame:table1Frame];
    //[_tableView2.scrollViewContainer setFrame:table2Frame];
    
    //设置MessageViews
    _messageViews = [[NSView alloc] initWithFrame:tabFrame];
    
    _messageTextView1 = [[MessageTextView alloc] initWithFrame:tabFrame];
    _messageTextView1.wantsLayer = YES;
    _messageTextView1.layer.backgroundColor = [NSColor redColor].CGColor;
    
   // _messageTextView2 = [[MessageTextView alloc] initWithFrame:tabFrame];
    
    [_messageTextView1.scrollViewContainer setFrame:table1Frame];
    //[_messageTextView2.scrollViewContainer setFrame:table2Frame];
    
    [_messageTextView1.textEdit setEditable:NO];
    //[_messageTextView2.textEdit setEditable:NO];
    [_tableViews addSubview:_tableView1];
  //[_tableViews addSubview:_tableView2];

    
    [_messageViews addSubview:_messageTextView1];
  //[_messageViews addSubview:_messageTextView2];

    
    [self addSubview:_tableViews];
    [self addSubview:_messageViews];
    
    [_tableViews setHidden:NO];
    [_messageViews setHidden:YES];
}

@end
