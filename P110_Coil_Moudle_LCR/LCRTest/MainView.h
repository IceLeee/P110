//
//  MainView.h
//  BenchTest
//
//  Created by Wade on 16/6/8.
//  Copyright © 2016年 Luxshare-ICT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CGDefine.h"
#import "TitleView.h"
#import "BottomView.h"
#import "RuntimeView.h"
#import "TableViewController.h"
#import "TabViewController.h"
#import "ICTSerialComm.h"
#import "CreateCSVFile.h"
#import "MessageTextView.h"
#import "InstantPudding.h"
#import "StatisticsView.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/serial/ioss.h>
#include <IOKit/IOBSD.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>

@interface MainView : NSView <NSTextFieldDelegate,NSComboBoxDelegate,NSComboBoxDataSource> {
    NSComboBox *_comboBox[2];
}

@property(retain)TabViewController *tabViewController;
@property(retain)NSSegmentedControl *segmentedController;
@property(retain)NSTextField *statusTextView;
@property(retain)NSArray *infoData;
@property(retain)NSMutableArray *commandData1;
@property(retain) RuntimeView *timeView1;
@property(retain) TitleView *titleView;
@property(retain) BottomView *bottomView;

@property(retain) NSString *strSWName;
@property(retain) NSString *strSWVersion;
@property(retain) NSString *strStationID;

@property BOOL Start;
@property BOOL isStart;
@property BOOL fSelectAll;

@property(retain)NSTextField *editASN1;
@property(retain)NSTextField *editFSN1;
@property(retain)NSTextField *editConfig1;
@property(retain)NSTextField *editDescription;

@property(retain)NSTextField *editStatus1;

//EEEECode & Config
@property(retain) NSDictionary *dictFourE;
@property(retain) NSDictionary *dictConfig;
//int _iTestState; //0:Waiting 1:StartTesting 2:Completed
@property int iTestState1;
@property int iTestState2;
@property int iTestState3;

@property BOOL bTestResult1;
@property BOOL bTestResult2;
@property BOOL bTestResult3;

@property(retain) NSString *strSN1;
@property(retain) NSString *strCoilSN1;
@property(retain) NSString *strUpperFerriteSN1;
@property(retain) NSString *strLowerFerriteSN1;//两个ferriteSN
@property(retain) NSString *strReturn1;
@property(retain) NSString *strReturn2;
//@property(retain) NSString *strConfig1;
@property(retain) NSString *strDescription;

@property(retain) NSString *strStartTime1;
@property(retain)NSString *strStopTime1;
@property NSTimeInterval startTimeInterval1;
@property NSTimeInterval stopTimeInterval1;
@property(retain)NSString *strTestTime1;

@property(retain) NSMutableString *strTotalResBuffer1;
@property(retain) NSString *strPortStatus;

//@property(retain) StatisticsView * statisticsView;

@property BOOL bAlreadyExistModem;
@property(retain) ICTSerialComm *commMCU;
@property(retain) ICTSerialComm *visaLCR;

@property(retain) NSString *strMcuPortName;
@property(retain) NSString *strLCRPortName;

@property(retain) NSCondition *conditionSerial;

@property(retain) NSString *strLayer;

@property(retain) NSString *testFixture;

//卡关
//@property(assign) BOOL bCheckSFC;
@property(assign) int iSNL;  //条码长度


//工单号
@property NSMutableArray *comboBoxConf;
@property NSMutableArray *comboBoxLine;
@property NSInteger indexForConf;
@property NSInteger indexForLine;

//PDCA

@property (retain) InstantPudding *pdca1;
@property(retain) NSString *strSFCUrl;

//治具
@property (retain) NSString *waitTime1;
@property (retain) NSString *waitTime2;

@property(assign) NSString *avgTime;

//calculate
//@property(assign) NSString *strF;
@property(assign) float F;
@property(assign) NSString *strLS;
@property(assign) NSString *strRS;
@property(assign) NSString *strQ;

@property(retain) NSString *strYanzheng;
@property (retain) StatisticsView * statisticsView;

@property(retain) NSString *strConfig1;
@property(retain) NSString *strFerriteConfig1;


@property(retain) NSString *strSpecialBuildName;
@property(copy)NSString *strConfig;

@property BOOL bobcat;


- (void)close;

@end
