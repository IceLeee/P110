//
//  MainView.m
//  BenchTest
//
//  Created by Wade on 16/6/8.
//  Copyright © 2016年 Luxshare-ICT. All rights reserved.
//

#import "MainView.h"

#define kStartButtonTag         101
#define kEEButtonTag            102
#define kIQCButtonTag           103
#define kConfigEditViewTag      104
#define kCheckButtonTag         105
#define kButtonSpecial          601

#define PI 3.1415926

NSString* const MESSAGE_TO_UPDATE_UI = @"MESSAGE_TO_UPDATE_UI";
extern NSString* const MACOS_COMM_RECVSIGNAL_CHAR;     //notification for receive data

@implementation MainView

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _commandData1 = [[NSMutableArray alloc] initWithCapacity:3];
        _strTotalResBuffer1 = [[NSMutableString alloc] initWithCapacity:3];
      
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotificationHandle:)
                                                     name:MESSAGE_TO_UPDATE_UI
                                                   object:self];
        
        _pdca1 = [[InstantPudding alloc] init];
        
        _strSFCUrl = [self getSFCURL];
        
        _strPortStatus = [[NSString alloc] initWithFormat:@""];
    }
    
    return self;
}

- (void)close
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_TO_UPDATE_UI object:self];
    
    if ([_commMCU Open]) {
        [_commMCU close];
    }
    
    if ([_visaLCR Open]) {
        [_visaLCR close];
    }

}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
    static int iFisrt = 0;
    
    if (iFisrt == 0) {
        NSMutableArray* dict1 =[[NSMutableArray alloc] initWithCapacity:3];
        NSMutableArray* dict2 =[[NSMutableArray alloc] initWithCapacity:3];
        [self enumSerialPorts:dict1];
        [self findUSBDevices:dict2];
        NSLog(@"MCU 名称 :%@",dict1);
        NSLog(@"LCR 名称 :%@",dict2);
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"TestConfig" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        
        for (NSString *str in dict1) {
            //NSLog(@"str = %@",str);
            if ([str hasPrefix:@"/dev/tty.usbserial"]) {
                NSLog(@"MCU 名称%@",str);
                [dict setValue:str forKey:@"McuPortName"];
            }
        }
        
        for (NSString *str in dict2) {
            //NSLog(@"str = %@",str);
            if ([str hasPrefix:@"USB0::"]) {
                NSLog(@"LCR 名称%@",str);
                [dict setValue:str forKey:@"LCRPortName"];
            }
        }
        
        //写入plist文件
        if ([dict writeToFile:path atomically:YES])
        {
           
        }

        [self initTestConfigFile];
        [self initTestScriptFile];
        [self initAllControllers];
        [self initAllDevices];
        
        iFisrt++;
    }
}

- (void)initTestConfigFile
{
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"TestConfig" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    _strSWName = [dict objectForKey:@"SW_Name"];
    _strSWVersion =[dict objectForKey:@"SW_Version"];
    _strStationID = [dict objectForKey:@"Station_ID"];
    _strSpecialBuildName = [dict objectForKey:@"SpecialBuildName"];
    _waitTime1 = [dict objectForKey:@"WaitTime1"];
    _waitTime2 = [dict objectForKey:@"WaitTime2"];
  
    _strMcuPortName = [[dict objectForKey:@"McuPortName"] copy];
    _strLCRPortName = [[dict objectForKey:@"LCRPortName"] copy];
    
    _comboBoxLine = [dict objectForKey:@"Lines"];
    _comboBoxConf = [dict objectForKey:@"Configs"];
    
    //_bCheckSFC = [[dict objectForKey:@"CheckSFC"] boolValue];
    
    _iSNL = [[dict objectForKey:@"SNLength"] intValue];
    _avgTime = [dict objectForKey:@"AVGTime"];
    _dictFourE = [dict objectForKey:@"EEEECode"];
    _dictConfig  = [dict objectForKey:@"Config"];
   // _dict21SNConfig = [dict objectForKey:@"Config"];
    _testFixture = [self getComputerNameForTestFixture];
}

- (void)initTestScriptFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestScript" ofType:@"plist"];
    _infoData = [NSArray arrayWithContentsOfFile:path] ;
    
    int index = 1;
    
    for (int i = 0; i < [_infoData count]; i++) {
        NSMutableDictionary *comdict = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        NSString *strHideOrShow = [[_infoData objectAtIndex:i] objectForKey:@"HideOrShow"];
        [comdict setObject:strHideOrShow  forKey:@"HideOrShow"];
        
        if ([strHideOrShow isEqualToString:@"show"]) {
            NSString *strID = [NSString stringWithFormat:@"%d", index];
            [comdict setObject:strID  forKey:@"ID"];
            
            NSString *strTestItem = [[_infoData objectAtIndex:i] objectForKey:@"TestItem"];
            [comdict setObject:strTestItem  forKey:@"TestItem"];
            
            NSString *strTestLower = [[_infoData objectAtIndex:i] objectForKey:@"Lower"];
            [comdict setObject:strTestLower  forKey:@"Lower"];
            
            NSString *strTestUpper = [[_infoData objectAtIndex:i] objectForKey:@"Upper"];
            [comdict setObject:strTestUpper  forKey:@"Upper"];
            
            NSString *strTestUnit = [[_infoData objectAtIndex:i] objectForKey:@"Unit"];
            [comdict setObject:strTestUnit  forKey:@"Unit"];
            
            [comdict setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
            
            [_commandData1 addObject:comdict];
            
            index++;
        }
    }
}

- (void)initAllDevices
{
    [self initSerialDevice];
    
}

- (void)initSerialDevice
{
    NSString *strStatus = [[NSString alloc] initWithFormat:@""];
    NSString *strTmp = @"Initial device !";
    
    [_statusTextView setTextColor:[NSColor blueColor]];
    [_statusTextView setStringValue:strTmp];
    
    if (_commMCU == nil) {
        _commMCU = [[ICTSerialComm alloc] init];
        if (![_commMCU open:_strMcuPortName
                   BaudRate:BAUDRATE_9600
                   DataBits:DATA_BITS_DEFAULT
                    StopBit:STOP_BITS_DEFAULT
                     Parity:PARITY_DEFAULT
                FlowControl:FLOW_CONTROL_DEFAULT]) {
            strStatus = [strStatus stringByAppendingString:@"MCU "];
        } else {
            NSLog(@"Open MCU sucessed!");
            
        }
    }
    
    if (_visaLCR == nil) {
        _visaLCR = [[ICTSerialComm alloc] init];
        if (![_visaLCR open:_strLCRPortName]) {
            strStatus = [strStatus stringByAppendingString:@"LCR "];
        } else {
            NSLog(@"Open LCR sucessed!");
            [_visaLCR write:[NSString stringWithFormat:@"APER MED,%d",_avgTime.intValue] type:@"visa"];
        }
    }

    if ([strStatus length] > 0) {
        strTmp = [NSString stringWithFormat:@"Open %@ failed!!!", strStatus];
        [_statusTextView setTextColor:[NSColor redColor]];
    } else {
        strTmp = @"Open all Device succeed!!!";
        [_statusTextView setTextColor:[NSColor greenColor]];
    }
    
    if ([_strPortStatus length] > 0) {
        strTmp = [NSString stringWithFormat:@" %@ %@ error!!! Please reopen app!!!", strTmp, _strPortStatus];
        [_statusTextView setTextColor:[NSColor redColor]];
    }
    
    [_statusTextView setStringValue:strTmp];
}

- (void)initAllControllers
{
    [self initSegmentedController];
    
    [self initDescriptionLabel];
    [self initDescriptionEdit];
    
    [self initASNLable1];
    [self initASNEdit1];
    
    [self initFSNLabel1];
    [self initFSNEdit1];
    
    [self initStatusEditFixture1];
    [self initRuntimeView1];
    [self initStartButton];
    [self initButtonSpecial];
    //[self initLineLabel1];
   // [self initLineComboBox1];
    
    //[self initCheckButton];
    
    NSRect titleFrame = NSMakeRect(TITLEVIEW_X, TITLEVIEW_Y, TITLEVIEW_WIDTH, TITLEVIEW_HEIGHT);
    _titleView = [[TitleView alloc] initWithFrame:titleFrame];
    [self addSubview:_titleView];
    
    NSRect bottomFrame = NSMakeRect(BOTTOMVIEW_X, BOTTOMVIEW_Y, BOTTOMVIEW_WIDTH, BOTTOMVIEW_HEIGHT);
    _bottomView = [[BottomView alloc] initWithFrame:bottomFrame];
    [self addSubview:_bottomView];
    
    NSRect tabViewFrame = NSMakeRect(TABVIEW_X, TABVIEW_Y, TABVIEW_WIDTH, TABVIEW_HEIGHT);
    _tabViewController = [[TabViewController alloc] initWithFrame:tabViewFrame];
    _tabViewController.tableView1.fSelected = NO;
    _tabViewController.tableView1.listData = _commandData1;
    [self addSubview:_tabViewController];
    
    NSRect statusFrame = NSMakeRect(FIXTURESTATUSVIEW_X, FIXTURESTATUSVIEW_Y-63, FIXTURESTATUSVIEW_WIDTH, FIXTURESTATUSVIEW_HEIGHT);
    _statusTextView = [[NSTextField alloc] initWithFrame:statusFrame];
    [_statusTextView setBackgroundColor:[NSColor controlHighlightColor]];
    [_statusTextView setFont:[NSFont boldSystemFontOfSize:14.0]];
    [_statusTextView setEditable:NO];
    [self addSubview:_statusTextView];
    
//    NSRect textViewFram = NSMakeRect(SFCTEXTVIEW_X, SFCTEXTVIEW_Y, SFCTEXTVIEW_WIDTH, SFCTEXTVIEW_HEIGHT);
//    _sfcTextView = [[MessageTextView alloc] initWithFrame:textViewFram];
//    [self addSubview:_sfcTextView];
//
    [self initStatisticsView];
    
    [_editASN1 becomeFirstResponder];
    NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                        target:self
                                                      selector:@selector(timerToDetectComPort)
                                                      userInfo:nil
                                                       repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSModalPanelRunLoopMode];
}

- (void)initStatisticsView {
    NSRect statisticsFrame = NSMakeRect(STATISTICSVIEW_X, STATISTICSVIEW_Y - TITLEVIEW_HEIGHT+33, STATISTICSVIEW_WIDTH+300, STATISTICSVIEW_HEIGHT);
    _statisticsView = [[StatisticsView alloc] initWithFrame:statisticsFrame];
    //[_statisticsView clearStatistics];//清空
    [self addSubview:_statisticsView];
}


- (void)initSegmentedController
{
    //设置seg的Frame
    NSRect segFrame = NSMakeRect((TABVIEW_WIDTH - 100)/2 + 20, SCREEN_HEIGHT - 165, 200, 40);
    
    _segmentedController = [[NSSegmentedControl alloc] initWithFrame:segFrame];
    [_segmentedController setSegmentStyle:NSSegmentStyleTexturedSquare];
    [_segmentedController setSegmentCount:2];
    [_segmentedController setLabel:@"Fun" forSegment:0];
    [_segmentedController setLabel:@"Log" forSegment:1];
    [_segmentedController setFont:[NSFont systemFontOfSize:15.0]];
    [_segmentedController setSelectedSegment:0];
    //    [[_segmentedController cell] setTag:201 forSegment:0];
    //    [[_segmentedController cell] setTag:202 forSegment:1];
    [_segmentedController setTarget:self];
    [_segmentedController setAction:@selector(segControlClicked:)];
    [_segmentedController setBounds:segFrame];
    [self addSubview:_segmentedController];
    //[_segmentedController release];
}

- (void)initStatusEditFixture1
{
    //设置Edit的Frame
    NSRect editFrame = NSMakeRect(STATUSVIEW1_X, STATUSVIEW1_Y, STATUSVIEW_WIDTH, STATUSVIEW_HEIGHT);
    
    _editStatus1 = [[NSTextField alloc]initWithFrame:editFrame];
    [_editStatus1 setStringValue:@"Wait_1"];
    [_editStatus1 setBackgroundColor:[NSColor lightGrayColor]];
    [_editStatus1 setAlignment:NSCenterTextAlignment];
    _editStatus1.textColor = [NSColor whiteColor];
    [_editStatus1 setFont:[NSFont boldSystemFontOfSize:30.0]];
    [_editStatus1 setBordered:YES];
    [_editStatus1 setEditable:NO];
    [self addSubview:_editStatus1];
    //[edit release];
}

- (void)initRuntimeView1
{
    NSRect timeFrame = NSMakeRect(TIMEVIEW1_X, TIMEVIEW1_Y, TIMEVIEW_WIDTH, TIMEVIEW_HEIGHT);
    _timeView1 = [[RuntimeView alloc] initWithFrame:timeFrame];
    [self addSubview:_timeView1];
}

- (void)initDescriptionLabel
{
    NSRect labelFrame = NSMakeRect(CONFIGLABEL1_X, CONFIGEDIT1_Y, CONFIGLABEL1_WIDTH + 35, CONFIGLABEL1_HEIGHT);
    
    NSTextField *label = [[NSTextField alloc]initWithFrame:labelFrame];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setStringValue:@"Description:"];
    [label setFont:[NSFont systemFontOfSize:16.0]];
    [label setBordered:NO];
    [label setEditable:NO];
    [self addSubview:label];
}

- (void)initDescriptionEdit
{
    NSRect editFrame = NSMakeRect(CONFIGEDIT1_X +95, CONFIGEDIT1_Y, CONFIGEDIT_WIDTH - 75, CONFIGLABEL1_HEIGHT);
    
    _editDescription = [[NSTextField alloc]initWithFrame:editFrame];
    [_editDescription setFont:[NSFont systemFontOfSize:18.0]];
    [_editDescription setTag:kConfigEditViewTag];
    //[_editDescription setDelegate:self];
    [_editDescription setBordered:YES];
    [_editDescription setEditable:YES];
    [self addSubview:_editDescription];
}

- (void)initASNLable1{
    NSRect frame = NSMakeRect(ASNLABEL1_X, ASNLABEL1_Y, ASNLABEL1_WIDTH, ASNLABEL1_HEIGHT);
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.backgroundColor = [NSColor clearColor];
    //label.alignment = NSCenterTextAlignment;
    label.stringValue = @"ASN:";
    label.font = [NSFont systemFontOfSize:16.0];
    //label.textColor = [NSColor orangeColor];
    label.bordered = 0;
    label.editable = 0;
    [self addSubview:label];
}

- (void)initASNEdit1
{
    NSRect textFrame = NSMakeRect(ASNEDIT1_X, ASNEDIT1_Y, ASNEDIT_WIDTH+20, ASNEDIT_HEIGHT);
    _editASN1 = [[NSTextField alloc] initWithFrame:textFrame];
    [_editASN1 setFont:[NSFont systemFontOfSize:16.0]];
    //[_editASN1 setStringValue:@"DLC2202001SH1WDL1"];
    //[_editASN1 setDelegate:self];
    [_editASN1 setBordered:YES];
    [_editASN1 setEditable:YES];
    //[_editASN1 setLineBreakMode: 4];
    [self addSubview:_editASN1];
}

- (void)initFSNLabel1
{
    //设置Label的Frame
    NSRect labelFrame = NSMakeRect(FSNLABEL1_X, FSNLABEL1_Y, FSNLABEL_WIDTH, FSNLABEL_HEIGHT);
    
    //创建一个运行时间标签
    NSTextField *label = [[NSTextField alloc]initWithFrame:labelFrame];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setTextColor:[NSColor blueColor]];
    [label setStringValue:@"FSN:"];
    [label setFont:[NSFont systemFontOfSize:16.0]];
    [label setBordered:NO];
    [label setEditable:NO];
    [self addSubview:label];
    //[label release];
}

- (void)initFSNEdit1
{
    NSRect textFrame = NSMakeRect(FSNEDIT1_X, FSNEDIT1_Y, FSNEDIT_WIDTH+20, FSNEDIT_HEIGHT);
    _editFSN1 = [[NSTextField alloc] initWithFrame:textFrame];
    [_editFSN1 setBackgroundColor:[NSColor clearColor]];
    [_editFSN1 setTextColor:[NSColor blueColor]];
    [_editFSN1 setFont:[NSFont systemFontOfSize:15.0]];
    [_editFSN1 setBordered:NO];
    [_editFSN1 setEditable:NO];
    [self addSubview:_editFSN1];
}

- (void)initStartButton
{
    NSRect btnFrame = NSMakeRect(580, 300, 120, 48);
    
    NSButton *btn = [[NSButton alloc]initWithFrame:btnFrame];
    [btn setBezelStyle:NSRegularSquareBezelStyle];
    [btn setTitle:@"Start"];
    [btn setFont:[NSFont systemFontOfSize:18.0]];
    [btn setTag:kStartButtonTag];
    [btn setTarget:self];
    //[btn setHidden:YES];
    [btn setAction:@selector(buttonAction:)];
    [self addSubview:btn];
}

- (void)initLineLabel1
{
    //设置Label的Frame
    NSRect labelFrame = NSMakeRect(580, 90, 80, 25);
    
    //创建一个运行时间标签
    NSTextField *label = [[NSTextField alloc]initWithFrame:labelFrame];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setStringValue:@"Line"];
    [label setFont:[NSFont systemFontOfSize:18.0f]];
    [label setBordered:NO];
    [label setEditable:NO];
    [self addSubview:label];
    //    [label release];
}

- (void)initLineComboBox1
{
    //设置comboBox的Frame
    NSRect comboFrame = NSMakeRect(640, 90, 225, 25);
    
    _comboBox[0] = [[NSComboBox alloc] initWithFrame:comboFrame];
    //[comboBox setTitleWithMnemonic:@"PreFunctional.plist"];
    
    [_comboBox[0] setUsesDataSource:YES];
    [_comboBox[0] setDataSource:self];
    [_comboBox[0] setDelegate:self];
    [_comboBox[0] setEditable:NO];
    //[_comboBox[0] setSelectable:YES];
    
    [_comboBox[0] selectItemAtIndex:0];//默认选中第一个
    
    [self addSubview:_comboBox[0]];
    //[comboBox release];
}


- (void)initCheckButton {
    NSRect btnFrame = NSMakeRect(TABLEVIEW1_WIDTH - 60, TABVIEW_HEIGHT + 100 , 80, 30);
    
    NSButton *btn = [[NSButton alloc]initWithFrame:btnFrame];
    [btn setBezelStyle:8];
    [btn setTitle:@"Calibrate"];
    [btn setImage:[NSImage imageNamed:@"titlebg.jpg"]];
    [btn setImagePosition:6];
    [btn setFont:[NSFont boldSystemFontOfSize:16.0]];
    [btn setTag:kCheckButtonTag];
    [btn setTarget:self];
    [btn setAction:@selector(buttonAction:)];
    [self addSubview:btn];
}

- (void)initButtonSpecial
{
    //设置button的Frame
    NSRect btnFrame = NSMakeRect(820, 245, 30, 30);
    
    //创建一个设置按钮
    NSButton *btn = [[NSButton alloc]initWithFrame:btnFrame];
    [btn setBezelStyle:NSRegularSquareBezelStyle];
    [btn setTitle:@""];
    [btn setFont:[NSFont systemFontOfSize:13.0]];
    [btn setTag:kButtonSpecial];
    [btn setTarget:self];
    //    [btn setAction:@selector(buttonAction:)];
    [self addSubview:btn];
    //[btn release];
}

- (void)timerToDetectComPort
{
    @autoreleasepool {
        NSButton *btn = (NSButton *)[self viewWithTag:kButtonSpecial];
        [btn performClick:btn];
    }
}


#pragma mark - NSTextField Delegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    
    if (commandSelector == @selector(insertNewline:)) {
        [self startButtonAction];
        
        result = YES;
    }
    
    return result;
}

#pragma mark - target action

- (void)segControlClicked:(id)sender
{
    int clickedSegment = (int)[sender selectedSegment];
    
    switch (clickedSegment) {
        case 0:
            [_tabViewController.tableViews setHidden:NO];
            [_tabViewController.messageViews setHidden:YES];
            break;
        case 1:
            [_tabViewController.tableViews setHidden:YES];
            [_tabViewController.messageViews setHidden:NO];
            break;
            
        default:
            break;
    }
}

- (void)buttonAction:(id)sender
{
    [_statusTextView setStringValue:@" "];
    NSButton *button = (NSButton *)sender;
    NSString *strSNTmp = nil;
    if (button.tag == kCheckButtonTag) {
        [self startCheckMeter];
    }
    
    if (button.tag == kStartButtonTag) {
        if (_isStart) {
            [self stopTestWithIndex:0];
        } else {
            _strDescription = [_editDescription stringValue];
            
            [_editASN1 selectText:_editASN1];
            //获取主条码并link coilSN
            _strSN1 = [_editASN1 stringValue];
            _strCoilSN1 = @"";
            NSLog(@"SFC URL is %@",_strSFCUrl);
            NSString* strParam = [NSString stringWithFormat:@"p=Getconfig&c=Query_History&sn=%@", _strSN1];
            _strCoilSN1 = [self sendRequestSync:@"http://10.32.13.55/bobcat/sfc_response.aspx" withParam:strParam TimeOut:10.0];
          
            NSLog(@"获取的返回值为%@",_strCoilSN1);
            
            if ([_strCoilSN1 rangeOfString:@"PASS"].length > 0) {
                
                 _strCoilSN1 = [self getData:_strCoilSN1 startSet:@"config=" endSet:nil];
                NSLog(@"条码%@",_strCoilSN1);
            } else {
                
                [_statusTextView setTextColor:[NSColor redColor]];
                [_statusTextView setStringValue:@"Config link fail "];
                //[self showAlertViewWarning:@"该Ferrite SN 未关联Coil SN！"];
                [_editASN1 setStringValue:@""];
                [_editASN1 setEditable:YES];
                return;
            }
        
            strSNTmp = _strSN1;
            
            _F = 0;
            _strLS = nil;
            _strRS = nil;
            _strQ = nil;
            
            
            if ( _strSN1.length == _iSNL)
            {
                //条码长度正确的时候开始卡关
//                if ([self getQuerySFCON]) {
//                    NSString *strParam = [NSString stringWithFormat:@"c=QUERY_RECORD&sn=%@&tsid=%@&p=UNIT_PROCESS_CHECK", [strSNTmp substringToIndex:17], _testFixture];
//                    NSString *strReturn = [self sendRequestSync:_strSFCUrl withParam:strParam TimeOut:10.0f];
//                    NSLog(@"strReturn = %@",strReturn);
//                    if ([strReturn length] > 0) {
//                        NSString *strTmp = [self getData:strReturn startSet:@"unit_process_check=" endSet:nil];
//                        NSLog(@"strTmp = %@",strTmp);
//                        if([strTmp rangeOfString:@"OK"].length > 0) {
                            [self startTestWithIndex:0];
//
//                        } else {
//
//                            [_editASN1 setStringValue:@""];
//                            [_statusTextView setTextColor:[NSColor redColor]];
//                            [_statusTextView setStringValue:strTmp];
//                            //[self showAlertViewWarning:strTmp];
//
//                        }
//                    }
//                } else {
//                    [_editASN1 setStringValue:@""];
//                    [_statusTextView setTextColor:[NSColor redColor]];
//                    [_statusTextView setStringValue:@"GH里卡关未开！"];
//                    //[self showAlertViewWarning:@"GH里卡关未开！"];
//                }
                
            } else {
                [_editASN1 setStringValue:@""];
                [self showAlertViewWarning:@"条码有误，请重测！"];
            }
            
        }
    }
}

#pragma mark -

- (void)startTestWithIndex:(int)index
{
    
    NSString *strSNTmp = nil;
    strSNTmp = _strSN1;
    //EEEE
    if (strSNTmp.length > 15) {
        NSString *strFourE = [strSNTmp substringWithRange:NSMakeRange(11, 4)];
        
        _strLayer = strFourE;
        
//        for (NSString *str in _dictFourE) {
//            //NSLog(@"str = %@",str);
//            if ([strFourE isEqualToString:str]) {
//                _strLayer = _dictFourE[str] ;
//            }
//        }
    }
    
//    if (strSNTmp.length >= 21) {
//        NSString *strConf = [strSNTmp substringWithRange:NSMakeRange(20, 1)];
//
//        _str21SNConfig1 = @"SN Error";
//
//        for (NSString *str in _dict21SNConfig) {
//            //NSLog(@"str = %@",str);
//            if ([strConf isEqualToString:str]) {
//                _str21SNConfig1 = _dict21SNConfig[str] ;
//            }
//        }
//
//    }
//
//    NSLog(@"主条码config: %@",_str21SNConfig1);
    //Config
    if (_strCoilSN1.length >= 22) {
        NSString *strConf = [_strCoilSN1 substringWithRange:NSMakeRange(21, 1)];
        
        _strCoilSNConfig1 = @"SN Error";
        
        for (NSString *str in _dictConfig) {
            //NSLog(@"str = %@",str);
            if ([strConf isEqualToString:str]) {
                _strCoilSNConfig1 = _dictConfig[str] ;
            }
        }
        
    }
    
    dispatch_queue_t queue = dispatch_queue_create("Perform Commands", nil);
    
    dispatch_async(queue, ^{
        [_commMCU write:@"2" type:@"serial"];
        [NSThread sleepForTimeInterval:_waitTime1.floatValue];
    });

    
    _isStart = YES;
    switch (index) {
        case 0:
            _iTestState1 = 1;
            //_strSN1 = [_editASN1 stringValue];
            //_strConfig1 = [_editConfig1 stringValue];
            
            [_editFSN1 setStringValue:@""];
            _strStartTime1 = [self getCurrentTime];
            _startTimeInterval1 = [NSDate timeIntervalSinceReferenceDate];
            [_timeView1 startRuntime];
           
            break;
        case 1:
            _iTestState2 = 1;
           
            break;
            
        default:
            break;
    }
    
    [self setStatusEditWithIndex:index withState:1];
    [self clearOutputDataWithIndex:index];
    
    [[[_tabViewController.messageTextView1.textEdit textStorage] mutableString] setString:@""];
    
    //dispatch_queue_t queue = dispatch_queue_create("Perform Commands", nil);
    dispatch_async(queue, ^{
        //开始测试
        [self performCommandsWithIndex:index];
        
        //回到主线程
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([NSThread isMainThread]) {
                NSLog(@"It is main thread");
                
                [self uploadToPDCAwithIndex:index];
                
                [self createSingleCSVFileWithIndex:index];
                [self createAllCSVFileWithIndex:index];
                [self stopTestWithIndex:index];
                    
                [_commMCU write:@"1" type:@"serial"];
                [NSThread sleepForTimeInterval:_waitTime2.floatValue];
            }
        });
    });
}

- (void)stopTestWithIndex:(int)index
{
    _isStart = NO;
    switch (index) {
        case 0:
            _iTestState1 = 2;
            
            [_editFSN1 setStringValue:_strSN1];
            
            [_editASN1 setStringValue:@""];
            //[_editConfig1 setStringValue:@""];
            break;
        case 1:
            _iTestState2 = 2;
            
            break;
            
        default:
            break;
    }
    
    [self setStatusEditWithIndex:index withState:2];
}

- (void)clearOutputDataWithIndex:(int)index
{
    TableViewController *tableViewTmp = nil;
    NSTextView *textEditTmp = nil;
    
    switch (index) {
        case 0:
        {
            tableViewTmp = _tabViewController.tableView1;
            textEditTmp = _tabViewController.messageTextView1.textEdit;
            
            for (int i = 0; i < [_tabViewController.tableView1.listData count]; i++) {
                NSDictionary *item =[_tabViewController.tableView1.listData objectAtIndex:i];
                NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
                [newItem removeObjectForKey:@"TestResult"];
                [newItem setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
                [_tabViewController.tableView1.listData setObject:newItem atIndexedSubscript:i];
            }
        }
            break;
        case 1:
        {
            tableViewTmp = _tabViewController.tableView2;
            textEditTmp = _tabViewController.messageTextView2.textEdit;
            
            for (int i = 0; i < [_tabViewController.tableView2.listData count]; i++) {
                NSDictionary *item =[_tabViewController.tableView2.listData objectAtIndex:i];
                NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
                [newItem removeObjectForKey:@"TestResult"];
                [newItem setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
                [_tabViewController.tableView2.listData setObject:newItem atIndexedSubscript:i];
            }
        }
            break;
            
        default:
            break;
    }
    
    [tableViewTmp.listView reloadData];
    [tableViewTmp setNeedsDisplay:YES];
    [[[textEditTmp textStorage] mutableString] setString:@""];
}

- (void)NeedToReflashTableViewSelect:(NSInteger)iSelected withIndex:(int)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTableView *listViewTmp = nil;
        
        switch (index) {
            case 0:
                listViewTmp = _tabViewController.tableView1.listView;
                break;
            case 1:
                listViewTmp = _tabViewController.tableView2.listView;
                break;
                
            default:
                break;
        }
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:iSelected];
        [listViewTmp selectRowIndexes:indexSet byExtendingSelection:NO];
        
        //        NSInteger iSelected = [listViewTmp selectedRow];
        NSRect rowRect = [listViewTmp rectOfRow:iSelected];
        NSRect viewRect = [[listViewTmp superview] frame];
        NSPoint scrollOrigin = rowRect.origin;
        scrollOrigin.y = scrollOrigin.y + (rowRect.size.height - viewRect.size.height)/2;
        
        if (scrollOrigin.y < 0)
            scrollOrigin.y = 0;
        
        [[[listViewTmp superview] animator] setBoundsOrigin:scrollOrigin];
    });
}

#pragma mark - test

- (void)performCommandsWithIndex:(int)indexPerform
{
    @autoreleasepool {
        int index = 0;
        int i = 0;
        
        ICTSerialComm *serialTmp = nil;
        //ICTSerialComm *visaUSBTmp = nil;
        
        for (; ((i < [_infoData count]) && ((_iTestState1 == 1) || (_iTestState2 == 1))); i++) {
            NSString *strTestItem = [[_infoData objectAtIndex:i] objectForKey:@"TestItem"]; 
            NSString *strDevice = [[_infoData objectAtIndex:i] objectForKey:@"Device"];
            NSString *strPortType = [[_infoData objectAtIndex:i] objectForKey:@"PortType"];//串口类型
            NSString *strCommand = [[_infoData objectAtIndex:i] objectForKey:@"Command"];
            NSString *strParam = [[_infoData objectAtIndex:i] objectForKey:@"Property"];
            NSString *strResType = [[_infoData objectAtIndex:i] objectForKey:@"ResultType"];
            NSString *strLower = [[_infoData objectAtIndex:i] objectForKey:@"Lower"];
            NSString *strUpper = [[_infoData objectAtIndex:i] objectForKey:@"Upper"];
            NSString *strHideOrShow = [[_infoData objectAtIndex:i] objectForKey:@"HideOrShow"];
            
            float delayTime = [[[_infoData objectAtIndex:i] objectForKey:@"DelayTime"] floatValue];
            
            if ([strDevice isEqualToString:@"MCU"]) {
                switch (indexPerform) {
                    case 0:
                        serialTmp = _commMCU;
                        break;
                    case 1:
                        
                        break;
                        
                    default:
                        break;
                }
            } else if ([strDevice isEqualToString:@"LCR"]) {
                switch (indexPerform) {
                    case 0:
                        serialTmp = _visaLCR;
                        break;
                        
                    default:
                        break;
                }
            } else if ([strDevice isEqualToString:@"SELF"]) {
                switch (indexPerform) {
                    case 0:
                        serialTmp = nil;
                        break;
                        
                    default:
                        break;
                }
            }

            if ([strCommand length] > 0) {
                NSString *strNewLine = [NSString stringWithFormat:@"\n%@  Write command:\n%@", [self getCurrentTime], strCommand];
                [self outputMessageTextView:strNewLine withIndex:indexPerform];
            }
            
            if ([serialTmp isOpen] ) {
                if ([strParam isEqualToString:@"Write"]) {
                    //发
                    [serialTmp write:strCommand type:strPortType];
                    [NSThread sleepForTimeInterval:delayTime];
                } else if ([strParam isEqualToString:@"Read"]) {
                    //收
                    NSLog(@"=====Read=====");
                } else if ([strParam isEqualToString:@"WriteAndRead"]) {
                    //发和收
                    if (serialTmp != nil) {
                        [serialTmp write:strCommand type:strPortType];
                        [NSThread sleepForTimeInterval:delayTime];
                    }
                }
                
                if ([strResType rangeOfString:@"value"].length > 0) {
                    
                    //如果返回值类型为value，取值判断上下限
                    //if (serialTmp != nil) {
                        NSString *strResBuffer = [self setComandDataWithDevice:serialTmp withIndexCommand:index withIndexInfo:i withStyle:strResType withIndexFixture:indexPerform];
                        
                        //如果需要将结果show出来
                        if ([strHideOrShow isEqualToString:@"show"]) {
                            NSLog(@"strTestItem = %@, index = %d\n", strTestItem, index);
                            NSLog(@"strResBuffer:%@",strResBuffer);
                            [self NeedToReflashTableViewSelect:index withIndex:indexPerform];
                            index++;
                        }
                        [NSThread sleepForTimeInterval:delayTime];
                    //}
                } else if ([strResType rangeOfString:@"string"].length > 0) {
                    
                    NSString *strResBuffer = [self setComandDataWithDevice:serialTmp withIndexCommand:index withIndexInfo:i withStyle:strResType withIndexFixture:indexPerform];
    
                    if ([strHideOrShow isEqualToString:@"show"]) {
                        NSLog(@"strTestItem = %@, index = %d\n", strTestItem, index);
                        NSLog(@"strResBuffer:%@",strResBuffer);
                        [self NeedToReflashTableViewSelect:index withIndex:indexPerform];
                        index++;
                    }
                    [NSThread sleepForTimeInterval:delayTime];
                } else if ([strResType rangeOfString:@"other"].length > 0) {
                     NSString *strResultTmp = @"1";
                    
                    if ([strHideOrShow isEqualToString:@"show"]) {
                        NSLog(@"strTestItem = %@, index = %d\n", strTestItem, index);
                        NSLog(@"strResBuffer:%@",strResultTmp);
                        [self setCommandDataWithIndex:index WithResult:strResultTmp WithStatus:YES withIndexFixture:indexPerform];
                        [self NeedToReflashTableViewSelect:index withIndex:indexPerform];
                        index++;
                    } else {
                        NSString *strNewLine = [NSString stringWithFormat:@"\n%@  Set result:\n%@", [self getCurrentTime], strResultTmp];
                        [self outputMessageTextView:strNewLine withIndex:indexPerform];
                    }
                }
                
                if ([strTestItem rangeOfString:@"Frequency"].length > 0) {
                    //_strF = [self getData:strCommand startSet:@"Q" endSet:@"K"];
                    _F = [self getData:strCommand startSet:@"Q " endSet:@"K"].floatValue;
                }
            } else {
                //NSString *strResultTmp = @"No Read";
                if ([strTestItem rangeOfString:@"Q"].length > 0) {
                    NSLog(@"F = %f",_F);
                    NSLog(@"LS = %f",_strLS.floatValue);
                    NSLog(@"RS = %f",_strRS.floatValue);
                    
                    //_strQ =[NSString stringWithFormat:@"%.1f",2*PI*_strF.floatValue*_strLS.floatValue/_strRS.floatValue];
                    _strQ =[NSString stringWithFormat:@"%.2f",2*PI*_F*_strLS.floatValue/_strRS.floatValue];
                    
                    //NSLog(@"F = %f",_strF.floatValue);
                    //NSLog(@"LS = %f",_strLS.floatValue);
                    //NSLog(@"RS = %f",_strRS.floatValue);
                    NSLog(@"Q  = %f",_strQ.floatValue);
                    
                    if (![_strQ isEqualToString:@"nan"]) {
                        if ([self compareValue:_strQ withMax:strUpper andMin:strLower]) {
                           [self setCommandDataWithIndex:index WithResult:_strQ WithStatus:YES withIndexFixture:indexPerform];
                        } else {
                            [self setCommandDataWithIndex:index WithResult:_strQ WithStatus:NO withIndexFixture:indexPerform];
                        }
                    } else {
                        [self setCommandDataWithIndex:index WithResult:@"Error" WithStatus:NO withIndexFixture:indexPerform];
                    }
                } else if ([strTestItem rangeOfString:@"RS"].length > 0 && [strDevice rangeOfString:@"SELF"].length > 0) {
                    if (!(_strRS == nil)) {
                        if ([self compareValue:_strRS withMax:strUpper andMin:strLower]) {
                            [self setCommandDataWithIndex:index WithResult:_strRS WithStatus:YES withIndexFixture:indexPerform];
                        } else {
                            [self setCommandDataWithIndex:index WithResult:_strRS WithStatus:NO withIndexFixture:indexPerform];
                        }
                    } else {
                        [self setCommandDataWithIndex:index WithResult:@"No Read" WithStatus:NO withIndexFixture:indexPerform];
                    }
                    
                } else if ([strTestItem rangeOfString:@"Frequency"].length > 0) {
                    [self setCommandDataWithIndex:index WithResult:@"0" WithStatus:NO withIndexFixture:indexPerform];
                } else{
                    [self setCommandDataWithIndex:index WithResult:@"No Read" WithStatus:NO withIndexFixture:indexPerform];
                }

                if ([strHideOrShow isEqualToString:@"show"]) {
                    NSLog(@"strTestItem = %@, index = %d\n", strTestItem, index);
                    [self NeedToReflashTableViewSelect:index withIndex:indexPerform];
                    index++;
                }
                
                [NSThread sleepForTimeInterval:0.1f];
            }
            
        }
        switch (indexPerform) {
            case 0:
                [_timeView1 stopRuntime];
                _strStopTime1 = [self getCurrentTime];
                _stopTimeInterval1 = [NSDate timeIntervalSinceReferenceDate];
                _strTestTime1 = [NSString stringWithFormat:@"%.1f", (_stopTimeInterval1 - _startTimeInterval1)];
                
                break;
            case 1:
                
                break;
                
            default:
                break;
        }
        
    }
}

- (void)startButtonAction
{
    NSButton *btn = (NSButton *)[self viewWithTag:kStartButtonTag];
    [btn performClick:btn];
}

- (void)stopButtonAction
{
    NSButton *btn = (NSButton *)[self viewWithTag:kStartButtonTag];
    [btn setEnabled:YES];
    [btn performClick:btn];
}

- (void)showAlertViewWarning:(NSString *)strWarning
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:strWarning];
    //[alert setInformativeText:@"Fialed!Please ."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

- (void)startCheckMeter
{
    NSButton *btn1 = (NSButton *)[self viewWithTag:kCheckButtonTag];
    [btn1 setEnabled:NO];
    
    //if (_visaLCR == nil) {
    if (![_visaLCR Open]) {
        [self showAlertViewWarning:@"Check Error!"];
    }else {
        //[_commMcu writeCommand:@"closeall#"];
        [_visaLCR write:@"DISP:PAGE CSET" type:@"visa"];
        [NSThread sleepForTimeInterval:0.1f];
        
        [self showAlertViewWarning:@"请做开路校对准备！"];
        [_visaLCR write:@"CORR:OPEN" type:@"visa"];
        //[NSThread sleepForTimeInterval:25.0f];
        [NSThread sleepForTimeInterval:90.0f];
        
        [self showAlertViewWarning:@"请做短路校对准备！"];
        [_visaLCR write:@"CORR:SHOR" type:@"visa"];
        [NSThread sleepForTimeInterval:90.0f];
        
        [_visaLCR write:@"DISP:PAGE MEAS" type:@"visa"];
        [NSThread sleepForTimeInterval:0.1f];
        [self showAlertViewWarning:@"校准完成！"];
        
        //[_commMcu writeCommand:@"copen all#"];
    }
    
    NSButton *btn2 = (NSButton *)[self viewWithTag:kCheckButtonTag];
    [btn2 setEnabled:YES];
}

#pragma mark - data

- (void)outputMessageTextView:(NSString *)strMessage withIndex:(int)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([strMessage length] > 0) {
            NSTextView *textEditTmp = nil;
            
            switch (index) {
                case 0:
                    textEditTmp = _tabViewController.messageTextView1.textEdit;
                    break;
                case 1:
                    textEditTmp = _tabViewController.messageTextView2.textEdit;
                    break;
                    
                default:
                    break;
            }
            ////
            textEditTmp.backgroundColor = [NSColor blackColor];
            textEditTmp.textColor = [NSColor greenColor];
            
            [[[textEditTmp textStorage] mutableString] appendString:[NSString stringWithFormat:@"%@\n", strMessage]];
            
            NSRange rect = NSMakeRange(textEditTmp.string.length, 0);
            [textEditTmp scrollRangeToVisible:rect];
            //[_tabViewController.messageTextView setNeedsDisplay:YES];
        }
    });
}

- (BOOL)compareValue:(NSString*)value withMax:(NSString *)max andMin:(NSString *)min
{
    BOOL bRet = NO;
    
    if (([min isEqualToString:@"NA"] || [min isEqualToString:@""])
        && !([max isEqualToString:@"NA"] || [max isEqualToString:@""])) {
        if ([value floatValue] < [max floatValue]) {
            bRet = YES;
        }
    }
    else if (!([min isEqualToString:@"NA"] || [min isEqualToString:@""])
             && ([max isEqualToString:@"NA"] || [max isEqualToString:@""])){
        if ([value floatValue] > [min floatValue]) {
            bRet = YES;
        }
    }
    else if (([min isEqualToString:@"NA"] || [min isEqualToString:@""])
             && ([max isEqualToString:@"NA"] || [max isEqualToString:@""])){
        bRet = YES;
    }
    else{
        if ([value floatValue] > [min floatValue] && [value floatValue] < [max floatValue]) {
            bRet = YES;
        }
    }
    return bRet;
}

- (void)setCommandDataWithIndex:(int)index WithResult:(NSString *)strResult WithStatus:(BOOL)bStatus
               withIndexFixture:(int)indexFixture
{
    NSMutableArray *arrayData = nil;
    
    switch (indexFixture) {
        case 0:
            arrayData = _commandData1;
            break;
        case 1:
            //arrayData = _commandData2;
            break;
            
        default:
            break;
    }
    
    NSDictionary *item = [arrayData objectAtIndex:index];
    NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
    
    
    [newItem setObject:[NSNumber numberWithBool:bStatus] forKey:@"Status"];
    [newItem setObject:strResult forKey:@"TestResult"];
    
    [arrayData setObject:newItem atIndexedSubscript:index];
    
    NSString *strNewLine = [NSString stringWithFormat:@"\n%@  Test result:\n%@", [self getCurrentTime], strResult];
    [self outputMessageTextView:strNewLine withIndex:indexFixture];
    //[self outputMessageTextView:strResult withIndex:indexFixture];
    //[self NeedToReflashTableViewSelect:index withIndex:indexFixture];
}

- (NSString *)setComandDataWithDevice:(ICTSerialComm *)serialComm
                     withIndexCommand:(int)indexCommand
                        withIndexInfo:(int)indexInfo
                            withStyle:(NSString *)strStyle
                     withIndexFixture:(int)indexFixture
{
    NSString *strItem =[[_infoData objectAtIndex:indexInfo] objectForKey:@"TestItem"];
    NSString *strCommand = [[_infoData objectAtIndex:indexInfo] objectForKey:@"Command"];
    //NSString *strResSpec = [[_infoData objectAtIndex:indexInfo] objectForKey:@"ResultSpec"];
    NSString *strFrom = [[_infoData objectAtIndex:indexInfo] objectForKey:@"From"];
    NSString *strTo = [[_infoData objectAtIndex:indexInfo] objectForKey:@"To"];
    NSString *strPortType = [[_infoData objectAtIndex:indexInfo] objectForKey:@"PortType"];//串口类型
    NSString *strUnit = [[_infoData objectAtIndex:indexInfo] objectForKey:@"Unit"];
    NSString *strResBuffer = nil;
    NSMutableArray *arrayData = nil;
    
    switch (indexFixture) {
        case 0:
            arrayData = _commandData1;
            break;
        case 1:
            //arrayData = _commandData2;
            break;
            
                default:
            break;
    }
    
    NSDictionary *item = [arrayData objectAtIndex:indexCommand];
    NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
    
    if ([strStyle rangeOfString:@"value"].length > 0) {
        NSString *strLower = [[_infoData objectAtIndex:indexInfo] objectForKey:@"Lower"];
        NSString *strUpper = [[_infoData objectAtIndex:indexInfo] objectForKey:@"Upper"];
        
        if ([self getResultFromDevice:serialComm
                             withItem:strItem
                           withResult:&strResBuffer
                          withCommand:strCommand
                      withStartString:strFrom
                        withEndString:strTo
                            withLower:strLower
                            withUpper:strUpper
                                 withUnit:strUnit
                         withPortType:strPortType
                     withIndexFixture:indexFixture]) {
            [newItem setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
        } else {
            [newItem setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
        }
        
    } else if ([strStyle rangeOfString:@"string"].length > 0) {
        if ([self getResultFromDevice:serialComm
                             withItem:strItem
                           withResult:&strResBuffer
                          withCommand:strCommand
                      withStartString:strFrom
                        withEndString:strTo
                       //withSpecString:strResSpec
                             withUnit:strUnit
                         withPortType:strPortType
                     withIndexFixture:indexFixture]) {
            [newItem setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
        } else {
            [newItem setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
        }
    }
    
    if ([strResBuffer length] == 0) {
        strResBuffer = @"No Read";
    }
    
    [newItem setObject:strResBuffer forKey:@"TestResult"];
    [arrayData setObject:newItem atIndexedSubscript:indexCommand];
    
    NSString *strNewLine = [NSString stringWithFormat:@"\n%@  Test result:\n%@", [self getCurrentTime], strResBuffer];
    [self outputMessageTextView:strNewLine withIndex:indexFixture];
    //NSLog(@"strResBuffer :%@",strResBuffer);
    return strResBuffer;
}

- (BOOL)getResultFromDevice:(ICTSerialComm *)serial
                   withItem:(NSString *)strItem
                 withResult:(NSString **)resBuf
                 withCommand:(NSString *)strCmd
            withStartString:(NSString *)strStart
              withEndString:(NSString *)strEnd
                withUnit:strUnit
               withPortType:(NSString *)strType
           withIndexFixture:(int)indexFixture
{
    if (![serial isOpen]) {
        *resBuf = @"No Read";
        return NO;
    }
    
    NSString *result = nil;
    NSMutableString *strResBufferTmp = nil;
    
    switch (indexFixture) {
        case 0:
            strResBufferTmp = _strTotalResBuffer1;
            break;
        case 1:
            //strResBufferTmp = _strTotalResBuffer2;
            break;
            
        default:
            break;
    }
    
    [strResBufferTmp setString:@""];
    
    BOOL isGet = NO;
    static int times = 0;
    isGet = [serial read:&result type:strType];
    
    while (!isGet && (times < 3)) {
        [serial write:strCmd type:strType];
        [NSThread sleepForTimeInterval:0.2f];
        isGet = [serial read:&result type:strType];
        times++;
    }
    if (result.length > 0) {
         [strResBufferTmp appendString:result];
    }
    
    times = 0;
    
//    if ([serial read:&result type:strtype]) {
//       
//
//        [strResBufferTmp appendString:result];
//    }
    
    NSString *strRes = nil;
    
    if ([strResBufferTmp length] > 0) {
        //[self outputMessageTextView:_strTotalResBuffer];
        strRes = [self getData:strResBufferTmp startSet:strStart endSet:strEnd];
        float value = fabs([[NSString stringWithFormat:@"%@", strRes] floatValue]);
        
        if ([strUnit isEqualToString:@"mOhm"]) {
            strRes = [NSString stringWithFormat:@"%.2f", value*1000];
        } else if ([strUnit isEqualToString:@"uH"]) {
            strRes = [NSString stringWithFormat:@"%.3f", value* 1000000];
        } else if ([strUnit isEqualToString:@"uF"]) {
            strRes = [NSString stringWithFormat:@"%.2f", value * 1000000000];
        } else {
            strRes = [NSString stringWithFormat:@"%.2f", value];
        }

        [strResBufferTmp setString:strRes];
    } else {
        strRes = @"No Read";
    }
    
    if ([strItem rangeOfString:@"LS"].length > 0) {
        _strLS = strRes;
    } else if ([strItem rangeOfString:@"RS"].length > 0) {
        _strRS = strRes;
    }

    *resBuf = strRes;
    
//    if ([strItem rangeOfString:@"LS"].length > 0) {
//        _strLS = strRes;
//    } else if ([strItem rangeOfString:@"RS"].length > 0) {
//        _strRS = strRes;
//    }
    
    if ([strResBufferTmp length] > 0) {
        if (!([strRes rangeOfString:@"inf"].length > 0)) {
            //return NO;
            return YES;
        }
//        else {
//            return YES;
//        }
    }
//    else {
//        return NO;
//    }
    
    return NO;
}

- (BOOL)getResultFromDevice:(ICTSerialComm *)serial
                   withItem:(NSString *)strItem
                 withResult:(NSString **)resBuf
                 withCommand:(NSString *)strCmd
            withStartString:(NSString *)strStart
              withEndString:(NSString *)strEnd
                  withLower:(NSString *)strLower
                  withUpper:(NSString *)strUpper
                   withUnit:(NSString *)strUnit
               withPortType:(NSString *)strType
           withIndexFixture:(int)indexFixture
{
    if (![serial isOpen]) {
        return NO;
    }
    
    NSString *result = nil;
    NSMutableString *strResBufferTmp = nil;
    
    switch (indexFixture) {
        case 0:
            strResBufferTmp = _strTotalResBuffer1;
            break;
        case 1:
            //strResBufferTmp = _strTotalResBuffer2;
            break;
            
        default:
            break;
    }
    
    //NSMutableString *strTotalResBuffer = [[NSMutableString alloc] initWithCapacity:3];
    [strResBufferTmp setString:@""];
    
    BOOL isGet = NO;
    static int times = 0;
     isGet = [serial read:&result type:strType];
    
    while (!isGet && (times < 3)) {
        [serial write:strCmd type:strType];
        [NSThread sleepForTimeInterval:0.2f];
        isGet = [serial read:&result type:strType];
        times++;
    }
    
    if (result.length > 0) {
        [strResBufferTmp appendString:result];
    }

    times = 0;

    
//    if ([serial read:&result type:strType]) {
//        [strResBufferTmp appendString:result];
//    }
    
    NSString *strRes = nil;
    
    if ([strResBufferTmp length] > 0) {
        
        strRes = [self getData:strResBufferTmp startSet:strStart endSet:strEnd];
        double value = fabs([[NSString stringWithFormat:@"%@", strRes] doubleValue]);
        
        if ([strUnit isEqualToString:@"mOhm"]) {
            strRes = [NSString stringWithFormat:@"%.2f", value*1000];
        } else if ([strUnit isEqualToString:@"uH"]) {
            strRes = [NSString stringWithFormat:@"%.3f", value* 1000000];
        } else if ([strUnit isEqualToString:@"uF"]) {
            strRes = [NSString stringWithFormat:@"%.2f", value * 1000000000];
        } else {
            strRes = [NSString stringWithFormat:@"%.2f", value];
        }
        
        if ([strItem rangeOfString:@"LS"].length > 0) {
            _strLS = strRes;
        } else if ([strItem rangeOfString:@"RS"].length > 0) {
            _strRS = strRes;
        }


        if ([strRes floatValue] < 0) {
            strRes = @"0";
        }
        
        if ([strItem rangeOfString:@"DCR"].length > 0) {
            if ([strRes rangeOfString:@"inf"].length > 0|| strRes.doubleValue > 1000 ) {
                *resBuf = strRes;
                //[self showAlertViewWarning:@"Overload!\n探针未顶到位！"];
                return NO;
            }
        }
        
        if ([self compareValue:strRes withMax:strUpper andMin:strLower]) {
            *resBuf = strRes;
            return YES;
        }

    } else {
        strRes = @"No Read";
    }
    
//    if ([strItem rangeOfString:@"LS"].length > 0) {
//        _strLS = strRes;
//    } else if ([strItem rangeOfString:@"RS"].length > 0) {
//        _strRS = strRes;
//    }
    
    *resBuf = strRes;
    return NO;
}

- (NSString *)getData:(NSString *)fileContent startSet:(NSString *)strStart endSet:(NSString *)strEnd
{
    NSRange rangeStr;
    NSUInteger iPosStr;
    
    if ([strStart length] == 0) {
        iPosStr = 0;
        //substringFromIndex;截取字符串，从给定索引index到这个字符串的结尾
        fileContent = [fileContent substringFromIndex:iPosStr];
    } else {
        //rangeOfString；搜索字符
        if ([fileContent rangeOfString:strStart].length > 0)
        {
            rangeStr = [fileContent rangeOfString:strStart];
            iPosStr = (rangeStr.location + rangeStr.length);
            fileContent = [fileContent substringFromIndex:iPosStr];
        }
    }
    
    NSRange rangeStrEnd;
    NSUInteger iLengthStr;
    
    if ([strEnd length] == 0) {
        iLengthStr = [fileContent length];
    } else {
        if ([fileContent rangeOfString:strEnd].length > 0) {
            rangeStrEnd = [fileContent rangeOfString:strEnd];
            iLengthStr = rangeStrEnd.location;
        } else {
            iLengthStr = 0;
        }
        
    }
    
    NSString *strRet = [fileContent substringWithRange:NSMakeRange(0, iLengthStr)];
    
    return strRet;
}

#pragma mark - time
- (NSString *)getCurrentTime
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"YYYY-MM-dd_HH:mm:ss.SSS"];
    [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    //    [dateFormatter release];
    return currentTime;
}

- (NSString *)getCurrentTime2
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd_HH_mm_ss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    return currentTime;
}

- (NSString *)getCurrentDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    //    [dateFormatter release];
    return currentTime;
}

- (void)setStatusEditWithIndex:(int)index withState:(int)iState
{
    NSTextField *editTmp = nil;
    BOOL bTestResult = NO;

    switch (index) {
        case 0:
            editTmp = _editStatus1;
            bTestResult = _bTestResult1;
            break;
        case 1:
           
            break;
            
        default:
            break;
    }
    
    switch (iState) {
        case 0:
            [editTmp setStringValue:[NSString stringWithFormat:@"Wait_%d", (index+1)]];
            [editTmp setBackgroundColor:[NSColor lightGrayColor]];
            break;
        case 1:
            [editTmp setStringValue:@"Testing"];
            [editTmp setBackgroundColor:[NSColor yellowColor]];
            break;
        case 2:
            if (bTestResult) {
                [editTmp setStringValue:@"Pass"];
                [editTmp setBackgroundColor:[NSColor greenColor]];
                _statisticsView.passCount++;
                [_statisticsView reflashStatistics];
            } else {
                [editTmp setStringValue:@"Fail"];
                [editTmp setBackgroundColor:[NSColor redColor]];
                _statisticsView.failCount++;
                [_statisticsView reflashStatistics];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - handle

- (void)handleNotificationHandle:(NSNotification*)notification
{
    @autoreleasepool {
        if([[notification name] isEqualToString:MESSAGE_TO_UPDATE_UI])
        {
            TableViewController *tableView = nil;
            NSDictionary *dic = (NSDictionary *)notification.userInfo;
            tableView = [dic objectForKey:@"TableView"];
            NSRect rect = tableView.frame;
            BOOL fAmplify = [[dic objectForKey:@"Amplify"] boolValue];
            
            if (fAmplify) {
                rect.origin.y = 0;
                rect.size.height = TABVIEW_HEIGHT;
                
                if (tableView == _tabViewController.tableView1) {
                    [_tabViewController.tableView1 setHidden:NO];
                    [_tabViewController.tableView2 setHidden:YES];
                } else if (tableView == _tabViewController.tableView2) {
                    [_tabViewController.tableView1 setHidden:YES];
                    [_tabViewController.tableView2 setHidden:NO];
                }
            } else {
                if (tableView == _tabViewController.tableView1) {
                    rect.origin.y = TABLEVIEW1_Y;
                    rect.size.height = TABLEVIEW1_HEIGHT;
                } else if (tableView == _tabViewController.tableView2) {
                    rect.origin.y = TABLEVIEW2_Y;
                    rect.size.height = TABLEVIEW2_HEIGHT;
                }
                
                [_tabViewController.tableView1 setHidden:NO];
                [_tabViewController.tableView2 setHidden:NO];
            }
            
            [tableView.scrollViewContainer setFrame:rect];
        }
    }
}

#pragma mark - csvfile

- (void)createSingleCSVFileWithIndex:(int)index
{
    //  =================================
    NSMutableArray *muteArrName = [[NSMutableArray alloc] init];
    NSMutableArray *muteArrRet = [[NSMutableArray alloc] init];
    NSMutableArray *muteArrLower = [[NSMutableArray alloc] init];
    NSMutableArray *muteArrUpper = [[NSMutableArray alloc] init];
    NSMutableArray *muteArrUnit = [[NSMutableArray alloc] init];
    
    NSString *strTestResult = nil;
    NSString *strFailList = nil;
    NSMutableArray *muteArrFailList = [[NSMutableArray alloc] init];
    
    NSMutableArray *arrayTmp = nil;
    NSString *strStartTimeTmp = nil;
    NSString *strStopTimeTmp = nil;
    NSString *strTestTimeTmp = nil;
    NSString *strSNTmp = nil;
    NSString *strSNCoilTmp = nil;
   // NSString *strLineTmp = nil;
    NSString *strConfigTmp = nil;
    NSString *strDescriptionTmp = nil;
    NSString *strLayerTmp = nil;
    
    switch (index) {
        case 0:
            arrayTmp = _commandData1;
            strStartTimeTmp = _strStartTime1;
            strStopTimeTmp = _strStopTime1;
            strSNTmp = _strSN1;
            strSNCoilTmp = _strCoilSN1;
            //strLineTmp = _comboBox[0].stringValue;
           // strConfigTmp = _strConfig1;
            strDescriptionTmp = _strDescription;
            strTestTimeTmp = _strTestTime1;
            strLayerTmp = _strLayer;
            strConfigTmp = _strCoilSNConfig1;
            
            break;
        case 1:
            
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i < [arrayTmp count]; i++)
    {
        NSString *itemName = [[arrayTmp objectAtIndex:i] objectForKey:@"TestItem"];
        NSString *itemValue = [[arrayTmp objectAtIndex:i] objectForKey:@"TestResult"];
        NSString *itemLower = [[arrayTmp objectAtIndex:i] objectForKey:@"Lower"];
        NSString *itemUpper = [[arrayTmp objectAtIndex:i] objectForKey:@"Upper"];
        NSString *itemUnit = [[arrayTmp objectAtIndex:i] objectForKey:@"Unit"];
        
        [muteArrName addObject:itemName];
        [muteArrRet addObject:itemValue];
        [muteArrUpper addObject:itemUpper];
        [muteArrLower addObject:itemLower];
        [muteArrUnit addObject:itemUnit];
        
        if (![[[arrayTmp objectAtIndex:i] objectForKey:@"Status"] boolValue]) {
            [muteArrFailList addObject:itemName];
        }
    }
    
    if ([muteArrFailList count] > 0) {
        switch (index) {
            case 0:
                _bTestResult1 = NO;
                break;
            case 1:
                _bTestResult2 = NO;
                break;
                
            default:
                break;
        }
        
        strFailList = [muteArrFailList componentsJoinedByString:@";"];
        strTestResult = @"FAIL";
    } else {
        switch (index) {
            case 0:
                _bTestResult1 = YES;
                break;
            case 1:
                _bTestResult2 = YES;
                break;
                
            default:
                break;
        }
        
        strFailList = @"NA";
        strTestResult = @"PASS";
    }
    
    NSString *measureData = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\r\n",
                             strSNTmp,
                             strSNCoilTmp,
                             strLayerTmp,
                             strConfigTmp,
                             _strStationID,
                             strTestResult,
                             strFailList,
                             strStartTimeTmp,
                             strStopTimeTmp,
                             //strTestTimeTmp,
                             strDescriptionTmp,
                             [muteArrRet componentsJoinedByString:@","]];
    
    CreateCSVFile *csv = [[CreateCSVFile alloc] init];
    
    //NSString *filePath = [NSString stringWithFormat:@"/vault/LCRTest/%@/Single", [self getCurrentDate]];
     NSString *filePath = [NSString stringWithFormat:@"/vault/LCRTest/%@/Single",[self getData:_strSWName startSet:@"_" endSet:@""]];
    NSString *fileName = [NSString stringWithFormat:@"LCRTest_%@_%@",strSNTmp,[self getCurrentTime2]];
    
    [csv createFileWithPath:filePath WithName:fileName WithType:@"csv"];
    
    NSString *line0 = [NSString stringWithFormat:@"LCRTest,Version:%@\r\n", _strSWVersion];
    NSString *line1 = [NSString stringWithFormat:@"SerialNumber,CoilSN,EEEE Code,CoilSNConfig,StationID,Test Pass/Fail Status,Fail Items,StartTime,EndTime,Description,%@\r\n", [muteArrName componentsJoinedByString:@","]];
    NSString *line2 = [NSString stringWithFormat:@"Upper Limit----->,,,,,,,,,,%@\r\n", [muteArrUpper componentsJoinedByString:@","]];
    NSString *line3 = [NSString stringWithFormat:@"Lower Limit----->,,,,,,,,,,%@\r\n", [muteArrLower componentsJoinedByString:@","]];
    NSString *line4 = [NSString stringWithFormat:@"Measurement Unit----->,,,,,,,,,,%@\r\n", [muteArrUnit componentsJoinedByString:@","]];
    NSString *data = [NSString stringWithFormat:@"%@%@%@%@%@",line0, line1, line2, line3, line4];
    
    [csv appendDataToFileWithString:data];
    [csv appendDataToFileWithString:measureData];
    
    [muteArrName removeAllObjects];
    [muteArrRet removeAllObjects];
    [muteArrUpper removeAllObjects];
    [muteArrLower removeAllObjects];
    [muteArrUnit removeAllObjects];
}

- (void)createAllCSVFileWithIndex:(int)index
{
    //  =================================
    NSMutableArray *muteArrName = [[NSMutableArray alloc] init];
    NSMutableArray *muteArrRet = [[NSMutableArray alloc] init];
    NSMutableArray *muteArrLower = [[NSMutableArray alloc] init];
    NSMutableArray *muteArrUpper = [[NSMutableArray alloc] init];
    NSMutableArray *muteArrUnit = [[NSMutableArray alloc] init];
    
    NSString *strTestResult = nil;
    NSString *strFailList = nil;
    NSMutableArray *muteArrFailList = [[NSMutableArray alloc] init];
    
    NSMutableArray *arrayTmp = nil;
    NSString *strStartTimeTmp = nil;
    NSString *strStopTimeTmp = nil;
    NSString *strTestTimeTmp = nil;
    NSString *strSNTmp = nil;
    NSString *strSNCoilTmp = nil;
    //NSString *strLineTmp = nil;
    NSString *strConfigTmp = nil;
    NSString *strDescriptionTmp = nil;
    NSString *strLayerTmp = nil;
    
    switch (index) {
        case 0:
            arrayTmp = _commandData1;
            strStartTimeTmp = _strStartTime1;
            strStopTimeTmp = _strStopTime1;
            strSNTmp = _strSN1;
            strSNCoilTmp = _strCoilSN1;
           //strLineTmp = _comboBox[0].stringValue;
            strConfigTmp = _strCoilSNConfig1;
            strDescriptionTmp = _strDescription;
            strTestTimeTmp = _strTestTime1;
            strLayerTmp = _strLayer;
            
            break;
        case 1:
            
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i < [arrayTmp count]; i++)
    {
        NSString *itemName = [[arrayTmp objectAtIndex:i] objectForKey:@"TestItem"];
        NSString *itemValue = [[arrayTmp objectAtIndex:i] objectForKey:@"TestResult"];
        NSString *itemLower = [[arrayTmp objectAtIndex:i] objectForKey:@"Lower"];
        NSString *itemUpper = [[arrayTmp objectAtIndex:i] objectForKey:@"Upper"];
        NSString *itemUnit = [[arrayTmp objectAtIndex:i] objectForKey:@"Unit"];
        
        [muteArrName addObject:itemName];
        [muteArrRet addObject:itemValue];
        [muteArrUpper addObject:itemUpper];
        [muteArrLower addObject:itemLower];
        [muteArrUnit addObject:itemUnit];
        
        if (![[[arrayTmp objectAtIndex:i] objectForKey:@"Status"] boolValue]) {
            [muteArrFailList addObject:itemName];
        }
    }
    
    if ([muteArrFailList count] > 0) {
        switch (index) {
            case 0:
                _bTestResult1 = NO;
                break;
            case 1:
                _bTestResult2 = NO;
                break;
                
            default:
                break;
        }
        
        strFailList = [muteArrFailList componentsJoinedByString:@";"];
        strTestResult = @"FAIL";
    } else {
        switch (index) {
            case 0:
                _bTestResult1 = YES;
                break;
            case 1:
                _bTestResult2 = YES;
                break;
                
            default:
                break;
        }
        
        strFailList = @"NA";
        strTestResult = @"PASS";
    }
    
    //strStopTimeTmp = [self getCurrentTime];
    
    NSString *measureData = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\r\n",
                             strSNTmp,
                             strSNCoilTmp,
                             strLayerTmp,
                             strConfigTmp,
                             _strStationID,
                             strTestResult,
                             strFailList,
                             strStartTimeTmp,
                             strStopTimeTmp,
                             //strTestTimeTmp,
                             strDescriptionTmp,
                             [muteArrRet componentsJoinedByString:@","]];
    
    CreateCSVFile *csv = [[CreateCSVFile alloc] init];
    
    //    if (_btEE.state == 1) {
    //NSString *filePath = [NSString stringWithFormat:@"/vault/LCRTest/%@/All", [self getCurrentDate]];
    NSString *filePath = [NSString stringWithFormat:@"/vault/LCRTest/%@/All",[self getData:_strSWName startSet:@"_" endSet:@""]];
    NSString *fileName = [NSString stringWithFormat:@"LCRTest_%@", [self getCurrentDate]];
    
    [csv createFileWithPath:filePath WithName:fileName WithType:@"csv"];
    
    NSString *csvFilePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", fileName]];
    NSURL *fileURL = [NSURL fileURLWithPath:csvFilePath];
    
    NSError *err = nil;
    NSString *fileContent = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&err];
    //    NSLog(@"Error = %@", err);
    
    if (!([fileContent rangeOfString:@"LCRTest"].length > 0)) {
        NSString *line0 = [NSString stringWithFormat:@"LCRTest,Version:%@\r\n", _strSWVersion];
        NSString *line1 = [NSString stringWithFormat:@"SerialNumber,CoilSN,EEEE Code,CoilSNConfig,StationID,Test Pass/Fail Status,Fail Items,StartTime,EndTime,Description,%@\r\n", [muteArrName componentsJoinedByString:@","]];
        NSString *line2 = [NSString stringWithFormat:@"Upper Limit----->,,,,,,,,,,%@\r\n", [muteArrUpper componentsJoinedByString:@","]];
        NSString *line3 = [NSString stringWithFormat:@"Lower Limit----->,,,,,,,,,,%@\r\n", [muteArrLower componentsJoinedByString:@","]];
        NSString *line4 = [NSString stringWithFormat:@"Measurement Unit----->,,,,,,,,,,%@\r\n", [muteArrUnit componentsJoinedByString:@","]];
        NSString *data = [NSString stringWithFormat:@"%@%@%@%@%@",line0, line1, line2, line3, line4];
        
        [csv appendDataToFileWithString:data];
    }
    
    [csv appendDataToFileWithString:measureData];
    
    [muteArrName removeAllObjects];
    [muteArrRet removeAllObjects];
    [muteArrUpper removeAllObjects];
    [muteArrLower removeAllObjects];
    [muteArrUnit removeAllObjects];
}



#pragma mark - checkpoint

- (NSString *)sendRequestSync:(NSString *)urlStr withParam:(NSString *)strParam TimeOut:(float)fTime
{
    // 初始化请求, 这里是变长的, 方便扩展
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    // 设置,构造URL
    [request setURL:[NSURL URLWithString:urlStr]];
    //与服务器进行交互的HTTP方法
    [request setHTTPMethod:@"POST"];
    
    //http://172.17.32.16/bobcat/sfc_response.aspxRequest.Form:c=QUERY_RECORD&sn=ZB747000021&StationID=ITKS_A02-2FAP-01_3_CON-OQC&p=SHIPPING_SETTINGS
    NSData *postData = [strParam dataUsingEncoding:NSUTF8StringEncoding];
    [request setTimeoutInterval:fTime]; //响应时间2s
    [request setHTTPBody:postData];
    
    // 发送同步请求, data就是返回的数据
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (data == nil) {
        NSLog(@"send request failed: %@", error);
        return [NSString stringWithFormat:@"send request failed: %@", error];
    }
    //将相应的数据转换为字符串
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"response: %@", response);
    return response;
}

- (NSString *)getSFCURL
{
    NSString *strUrl = nil;
    //文件内容
    NSString* fileContent = [NSString stringWithContentsOfFile:@"/vault/data_collection/test_station_config/gh_station_info.json" encoding:NSUTF8StringEncoding error:nil];
    
    NSString *strRet = [self getData:fileContent startSet:@"\"SFC_URL\" : \"" endSet:@"\""];
    
    if ([strRet length] > 0) {
        strUrl = strRet;
    }
    
    return strUrl;
}

- (BOOL)getQuerySFCON
{
    return 0;
    BOOL bRet = NO;
    
    NSString* fileContent = [NSString stringWithContentsOfFile:@"/vault/data_collection/test_station_config/gh_station_info.json" encoding:NSUTF8StringEncoding error:nil];
    
    NSString *strRet = [self getData:fileContent startSet:@"SFC_QUERY_UNIT_ON_OFF" endSet:@","];
    NSLog(@"SFC_QUERY_UNIT_ON_OFF = %@",strRet);
    
    if ([strRet length] > 0) {
        if ([strRet rangeOfString:@"ON"].length > 0) {
            bRet = YES;
        }
    }
    
    return bRet;
}

#pragma mark - getComputerName

- (NSString *)getComputerNameForTestFixture
{
   return [[NSHost currentHost] localizedName];

}

#pragma mark - NSComboBoxDataSource Delegate
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    if (aComboBox == _comboBox[0]) {
        return [_comboBoxLine count];
    }else if( aComboBox == _comboBox[1]) {
        return [_comboBoxConf count];
    } else {
        return 0;
    }
    
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if (aComboBox == _comboBox[0] ) {
        if ([_comboBoxLine count] > 0) {
            return [_comboBoxLine objectAtIndex:index];
        }
    } else if (aComboBox == _comboBox[1]) {
        if ([_comboBoxConf count] > 0) {
            return [_comboBoxConf objectAtIndex:index];
        }
    }
    return nil;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox *aComboBox = (NSComboBox *)notification.object;
    int index = (int)[aComboBox indexOfSelectedItem];
    
    if (aComboBox == _comboBox[0]) {
        if ( index != _indexForLine) {
            _indexForLine = index;
            
            NSString *strMid = [_comboBoxLine objectAtIndex:0];
            [_comboBoxLine setObject:[_comboBoxLine objectAtIndex:index] atIndexedSubscript:0];
            [_comboBoxLine setObject:strMid atIndexedSubscript:index];
            
            
            
            NSLog(@"%@",[_comboBoxLine objectAtIndex:0]);
        }
    } else if (aComboBox == _comboBox[1]) {
        if ( index != _indexForConf) {
            _indexForConf = index;
            
            NSString *strMid = [_comboBoxConf objectAtIndex:0];
            [_comboBoxConf setObject:[_comboBoxConf objectAtIndex:index] atIndexedSubscript:0];
            [_comboBoxConf setObject:strMid atIndexedSubscript:index];
            
        }
    }
    
    [aComboBox selectItemAtIndex:0];//选择数值后再次选择默认值
    [self saveComboBoxValue];
    
    return;
}

- (void)saveComboBoxValue
{
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"TestConfig" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //    NSMutableArray *comboBoxLine = [[NSMutableArray alloc] initWithCapacity:2];
    //    NSMutableArray *comboBoxConf = [[NSMutableArray alloc] initWithCapacity:2];
    //
    //    [comboBoxLine addObject:_comboBoxLine];
    //    [comboBoxConf addObject:_comboBoxConf];
    
    [dict setValue:_comboBoxLine forKey:@"Lines"];
    [dict setValue:_comboBoxConf forKey:@"Configs"];
    
    
    if ([dict writeToFile:path atomically:YES]) {
        //[self showAlertViewWarning:@"保存成功!"];
    } else {
        [self showAlertViewWarning:@"保存Line/Config值失败！"];
    }
}

#pragma mark - PDCA
- (void)uploadToPDCAwithIndex:(int)index
{
    NSMutableArray *arrayTmp = nil;
    //NSString *strStartTimeTmp = nil;
    //NSString *strStopTimeTmp = nil;
    NSString *strSNTmp = nil;
    
    InstantPudding *pdcaTmp = nil;
    
    switch (index) {
        case 0:
            arrayTmp = _commandData1;
            strSNTmp = [_strSN1 substringToIndex:17];
            
            pdcaTmp = _pdca1;
            break;
        case 1:
            
            break;
        case 2:
            
            break;
            
        default:
            break;
    }
    
    
    //if ([_strDefaultPath length] > 0) {
    //PDCA
    if ([pdcaTmp IPStart]) {
        //            NSTextField *textTXField = (NSTextField*)[self viewWithTag:kTXEditViewTag];
        //            NSString *strSN = [textTXField stringValue];
        
        if ([pdcaTmp ValidateSerialNumber:strSNTmp]) {
            
            
            if (![pdcaTmp AddIPAttribute:@"softwarename" Value:_strSWName]) {
                NSLog(@"softwarename error");
            }
            
            if (![pdcaTmp AddIPAttribute:@"softwareversion" Value:_strSWVersion]) {
                NSLog(@"softwareversion error");
            }
            
            if (![pdcaTmp AddIPAttribute:@"ICT_BARCODE" Value:_strSN1]) {
                NSLog(@"ICT_BARCODE error");
            }
           
            if (![pdcaTmp AddIPAttribute:@"S_BUILD" Value:_strSpecialBuildName]) {
                NSLog(@"S_BUILD error");
            }
            
            if(_strLayer.length > 0)
            {
                if (![pdcaTmp AddIPAttribute:@"EEEECode" Value:_strLayer]) {
                    NSLog(@"EEEECode error");
                }
            }
            
            
            [pdcaTmp AddIPAttribute:@"serialnumber" Value:strSNTmp];
            
            
            
            
            //upload analyzed data
            for (int i = 0; i < [arrayTmp count] ; i++) {
                NSDictionary *dic = [arrayTmp objectAtIndex:i];
                
                [pdcaTmp AddIPTestItem:[dic objectForKey:@"TestItem"]
                             TestValue:[dic objectForKey:@"TestResult"]
                            LowerLimit:[dic objectForKey:@"Lower"]
                            UpperLimit:[dic objectForKey:@"Upper"]
                              Priority:IP_PRIORITY_REALTIME_WITH_ALARMS
                                 Units:[dic objectForKey:@"Unit"]];
            }
            
            [pdcaTmp IPDoneAndCommit:strSNTmp];
        }
    }
    // }
}

#pragma mark -
- (int)enumSerialPorts:(NSMutableArray *)array
{
    kern_return_t			kernResult;
    CFMutableDictionaryRef	classToMatch;
    io_iterator_t	serialPortIterator;
    io_object_t		modemService;
    
    int devicecount = 0;
    
    classToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    
    if(classToMatch == NULL){
        NSLog(@"IOServiceMatching return null dictionary.");
    } else {
        CFDictionarySetValue(classToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDAllTypes));
    }
    
    // Get an iterator across all matching devices.
    kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classToMatch, &serialPortIterator);
    //	    if (KERN_SUCCESS != kernResult) {
    //	        printf("IOServiceGetMatchingServices returned %d\n", kernResult);
    //			continue;
    //	    }
    if(KERN_SUCCESS != kernResult){
        //NSLog(@"IOServiceGetMatchingServices returned %d \n", kernResult);
    }
    // get device path
    while ((modemService = IOIteratorNext(serialPortIterator))) {
        CFTypeRef	bsdPathAsCFString;
        
        bsdPathAsCFString = IORegistryEntryCreateCFProperty(modemService,
                                                            CFSTR(kIODialinDeviceKey),
                                                            kCFAllocatorDefault,
                                                            0);
        if (bsdPathAsCFString) {
            NSString *str = [NSString stringWithFormat:@"%@", bsdPathAsCFString];
            
            if ([str rangeOfString:@"/dev/tty"].length > 0)
            {
                [array addObject:str];
                devicecount++;
            }
            CFRelease(bsdPathAsCFString);
        }
    }
    
    IOObjectRelease(modemService);
    IOObjectRelease(serialPortIterator);	// Release the iterator.
    return devicecount;
}

-(int)findUSBDevices:(NSMutableArray *)array
{
    char instrDescriptor[VI_FIND_BUFLEN];
    ViUInt32 numInstrs;
    ViFindList findList;
    ViSession defaultRM;
    ViStatus status;
    
    status = viOpenDefaultRM (&defaultRM);
    if (status < VI_SUCCESS)
    {
        printf("Could not open a session to the VISA Resource Manager!\n");
        viClose (defaultRM);
        return status;
    }
    status = viFindRsrc (defaultRM, "?*INSTR", &findList, &numInstrs, instrDescriptor);
    
    if (status < VI_SUCCESS)
    {
        printf ("An error occurred while finding resources.\nHit enter to continue.");
        viClose (defaultRM);
        return status;
    }
    
    [array addObject:[NSString stringWithUTF8String:instrDescriptor]];
    printf("%zd instruments resources found:\n\n", numInstrs);
    printf("%s \n",instrDescriptor);
    
    int itmp = numInstrs;
    
    while (--itmp)
    {
        /* stay in this loop until we find all instruments */
        status = viFindNext (findList, instrDescriptor);  /* find next desriptor */
        if (status < VI_SUCCESS)
        {   /* did we find the next resource? */
            printf ("An error occurred finding the next resource.\nHit enter to continue.");
            fflush(stdin);
            getchar();
            viClose (defaultRM);
            return status;
        }
        printf("%s \n",instrDescriptor);
        [array addObject:[NSString stringWithUTF8String:instrDescriptor]];
    }    /* end while */
    
    return numInstrs;
}


@end
