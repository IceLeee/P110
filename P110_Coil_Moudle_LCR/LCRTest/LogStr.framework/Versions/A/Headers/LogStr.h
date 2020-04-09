//
//  LogStr.h
//  Station
//
//  Created by jax on 2019/8/8.
//  Copyright © 2019 ict-luxshare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "util.h"


#define ICTLog(str) ZCLog([NSString stringWithFormat:@"%s第(%d)行:%@",__FUNCTION__,__LINE__,str]);


NS_ASSUME_NONNULL_BEGIN

/******Log 初始化***********
#import <LogStr/LogStr.h>
 
 
 - (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
 // Insert code here to initialize your application
 
 //打印log初始化配置
 LogStr * log = [LogStr shareTools];
 //下面两种2选1
 
 //使用默认配置，log在桌面输出
 // [log syncLogSetting];
 
 //自定义配置位置
 [log settingLogPath:@"/vault/Station/log.log"];
 
 
 
 
 }
 
 *************/

/*******Log 使用********
 #import <LogStr/util.h>
 
 logstr(@"viewDidLoad ...........");
 *************/





@interface LogStr : NSObject

//同步日志输出配置,默认配置
- (BOOL)syncLogSetting;

//设置log日志输出位置，可自定义log文件位置
- (BOOL)settingLogPath:(NSString *)path;

//单例
+(instancetype)shareTools;

//log 位置
- (NSString *)path;


void logstr(NSString *str);
void ZCLog(NSString *str);
@end





NS_ASSUME_NONNULL_END
