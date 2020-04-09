//
//  TableViewController.m
//  NationalTest
//
//  Created by jason on 15-3-30.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "TableViewController.h"

extern NSString* const MESSAGE_TO_UPDATE_UI;

@implementation TableViewController

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _listData = [[NSMutableArray alloc] initWithCapacity:3];
        _arraySelectedPara = [[NSMutableArray alloc] initWithCapacity:3];
        
        _fAmplify = NO;
        
        [self initTableViewController];
    }
    return self;
}

- (void)setListData:(NSMutableArray *)listData
{
    _listData = listData;
    
    if (_fSelected) {
        NSString *strTmp;
        
        for (int i = 0; i < [_listData count]; i++) {
            strTmp = @"1";
            [_arraySelectedPara addObject:strTmp];
        }
    }
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

- (void)initTableViewController
{
    //设置tableView的Frame
    NSRect tableViewFrame = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    
    //创建一个scrollView容器
    _scrollViewContainer = [[NSScrollView alloc] initWithFrame:tableViewFrame];
      _scrollViewContainer.hasVerticalScroller = YES;
    //创建TableView
    NSRect viewRect = [[_scrollViewContainer contentView] bounds];
	_listView = [[NSTableView alloc] initWithFrame:viewRect];
    [_listView setRowHeight:21];
    
	[_listView setBackgroundColor:[NSColor whiteColor]];
	[_listView setGridColor:[NSColor lightGrayColor]];
	[_listView setGridStyleMask:NSTableViewSolidHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask];
	[_listView setUsesAlternatingRowBackgroundColors:YES];
	[_listView setAutosaveTableColumns:YES];
	[_listView setAllowsEmptySelection:YES];
	[_listView setAllowsColumnSelection:YES];
    //[_listView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    //[_listView setDoubleAction:@selector(doubleClick:)];//双击事件
    
    [self addColumn:@"ID" withTitle:@"ID"];
    [self addColumn:@"TestItem" withTitle:@"TestItem"];
    [self addColumn:@"Lower" withTitle:@"Lower"];
    [self addColumn:@"Upper" withTitle:@"Upper"];
    [self addColumn:@"Unit" withTitle:@"Unit"];
    [self addColumn:@"TestResult" withTitle:@"TestResult"];
    
	[_listView setDataSource:self];
	[_scrollViewContainer setDocumentView:_listView];
	
	[self addSubview:_scrollViewContainer];
    //    [scrollViewContainer release];
}

#pragma mark -
#pragma mark NSTableViewDataSource Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (_listData != nil) {
        return [_listData count];
    } else {
        return 0;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSParameterAssert(row >= 0 && row < [_listData count]);
    
    id result = [[_listData objectAtIndex:row] objectForKey:[tableColumn identifier]];
    
    if ([[tableColumn identifier] isEqualToString:@"TestItem"] || [[tableColumn identifier] isEqualToString:@"TestResult"])
    {
//        [[tableColumn dataCellForRow:row] setDrawsBackground:YES];
//        [[tableColumn dataCellForRow:row] setBackgroundColor:[NSColor selectedControlColor]];
        [[tableColumn dataCellForRow:row] setAlignment:NSLeftTextAlignment];
    } else {
        [[tableColumn dataCellForRow:row] setAlignment:NSCenterTextAlignment];
    }
    
    if ([[tableColumn identifier] isEqualToString:@"TestResult"]) {
        if (![[[_listData objectAtIndex:row] objectForKey:@"Status"] boolValue]) {
            [[tableColumn dataCellForRow:row] setTextColor:[NSColor redColor]];
        }
        else{
            [[tableColumn dataCellForRow:row] setTextColor:[NSColor blueColor]];
        }
    }
    
    if (_fSelected) {
        if([[tableColumn identifier] isEqualToString:@"ID"]){
            NSButtonCell *cell = [[NSButtonCell alloc] init];
            [cell setButtonType:NSSwitchButton];
            [cell setTitle:[[_listData objectAtIndex:row] objectForKey:[tableColumn identifier]]];
            [cell setState:[[_arraySelectedPara objectAtIndex:row] integerValue]];
            [tableColumn setDataCell:cell];
            
            //        [cell setTag:(row + 300)];
            //        [cell setAction:@selector(cellClick:)];
            //        [cell setTarget:self];
            
            return cell;
        }
    }
    
    return result;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (_fSelected) {
        if([[tableColumn identifier] isEqualToString:@"ID"]){
            NSString *strTmp = (NSString*)[_arraySelectedPara objectAtIndex:row];
            
            if([strTmp isEqualToString:@"1"]) {
                strTmp=@"0";
            } else {
                strTmp=@"1";
            }
            
            [_arraySelectedPara replaceObjectAtIndex:row withObject:strTmp];
        }
    }
}

#pragma mark -
#pragma mark method

- (void)addColumn:(NSString*)newid withTitle:(NSString*)title
{
	NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:newid];
    
    [[column headerCell] setFont:[NSFont systemFontOfSize:14.0]];
	[[column headerCell] setStringValue:title];
	[[column headerCell] setAlignment:NSCenterTextAlignment];
    
    if ([newid isEqualToString:@"ID"]) {
        [column setWidth:50.0];
        [column setMinWidth:50];
    }else if ([newid isEqualToString:@"TestItem"]) {
        [column setWidth:150.0];
        [column setMinWidth:150];
    }else if ([newid isEqualToString:@"Lower"]) {
        [column setWidth:60.0];
        [column setMinWidth:20];
    }else if ([newid isEqualToString:@"Upper"]) {
        [column setWidth:60.0];
        [column setMinWidth:20];
    }else if ([newid isEqualToString:@"Unit"]) {
        [column setWidth:60.0];
        [column setMinWidth:20];
    }else if ([newid isEqualToString:@"TestResult"]) {
        [column setWidth:150.0];
        [column setMinWidth:100];
    }else {
	    [column setWidth:100.0];
	    [column setMinWidth:50];
    }
    
	[column setEditable:NO];
	[column setResizingMask:NSTableColumnAutoresizingMask | NSTableColumnUserResizingMask];
	[_listView addTableColumn:column];
//	[column release];
}
                                         
#pragma mark -
#pragma mark target action

- (void)doubleClick:(id)sender
{
    _fAmplify = !_fAmplify;
    
    NSMutableDictionary *newdict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [newdict setObject:[NSNumber numberWithBool:_fAmplify] forKey:@"Amplify"];
    [newdict setObject:self forKey:@"TableView"];
    
    id topView = [[[self superview] superview] superview];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_TO_UPDATE_UI
                                                        object:topView
                                                      userInfo:newdict];
}

-(void)cellClick:(id)sender
{
    NSButtonCell *cell = (NSButtonCell *)[sender selectedCell];
    
    if([cell state] == 1) {
        [cell setState:0];
    } else {
        [cell setState:1];
    }
}




@end
