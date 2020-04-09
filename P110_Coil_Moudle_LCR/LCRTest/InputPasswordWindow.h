//
//  InputPasswordWindow.h
//  CapMeasurement
//
//  Created by jason on 14-9-12.
//  Copyright (c) 2014年 Jason. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InputPasswordWindow : NSWindowController <NSTextFieldDelegate>
{
    BOOL _fConfirm;
}

@property(nonatomic, assign) BOOL fConfirm;

@end
