//
//  TableViewController.h
//  NationalTest
//
//  Created by jason on 15-3-30.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TableViewController : NSView <NSTableViewDataSource>
{
    NSScrollView *_scrollViewContainer;
    NSTableView *_listView;
    
    NSMutableArray *_listData;
    
    BOOL _fSelected;
    NSMutableArray *_arraySelectedPara;
    
    BOOL _fAmplify;
}

@property (retain, nonatomic) NSMutableArray *listData;
@property (retain, nonatomic) NSTableView *listView;
@property (retain, nonatomic) NSScrollView *scrollViewContainer;
@property (assign, nonatomic) BOOL fSelected;
@property (retain, nonatomic) NSMutableArray *arraySelectedPara;

@end
