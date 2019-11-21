//
//  CreateCSVFile.h
//  CreateCSVFile
//
//  Created by Weiding on 2017/8/15.
//  Copyright © 2017年 Luxshare-ICT. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CreateCSVFile : NSObject
{
    NSString *_logFilePath;
    NSMutableString *_sumStr;
}

- (id)init;
- (BOOL)createFileWithPath:(NSString *)path WithName:(NSString *)name WithType:(NSString *)type;
- (BOOL)appendDataToFile:(NSArray *)arrData;
- (BOOL)appendDataToFileWithArrar:(NSArray *)arrData orString:(NSString *)str withFlag:(BOOL)flag;
- (BOOL)appendDataToFileWithString:(NSString *)string;

@end
