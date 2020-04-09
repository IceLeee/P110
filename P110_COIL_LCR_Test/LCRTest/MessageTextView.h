//
//  MessageTextView.h
//  NationalTest
//
//  Created by Jason liang on 15-4-21.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MessageTextView : NSView
{
    NSScrollView *_scrollViewContainer;
    NSTextView *_textEdit;
}

@property (retain, nonatomic) NSTextView *textEdit;
@property (retain, nonatomic) NSScrollView *scrollViewContainer;

@end
