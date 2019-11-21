//
//  TabViewController.h
//  NationalTest
//
//  Created by Jason liang on 15-4-2.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TableViewController.h"
#import "MessageTextView.h"

@interface TabViewController : NSView
{
    NSScrollView *_scrollViewContainer;
    MessageTextView *_messageTextView;
    NSSegmentedControl *_segmentedController;
    
    NSView *_tableViews;
    NSView *_messageViews;
    
    TableViewController *_tableView1;
    TableViewController *_tableView2;
    
    MessageTextView *_messageTextView1;
    MessageTextView *_messageTextView2;
    
}

@property (retain, nonatomic) TableViewController *tableView1;
@property (retain, nonatomic) TableViewController *tableView2;

@property (retain, nonatomic) MessageTextView *messageTextView1;
@property (retain, nonatomic) MessageTextView *messageTextView2;

@property (retain, nonatomic) NSView *tableViews;
@property (retain, nonatomic) NSView *messageViews;

@end
