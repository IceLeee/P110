//
//  CGDefine.h
//  ApplicationTest
//
//  Created by Wade on 15/12/11.
//  Copyright (c) 2015年 Luxshare-ICT. All rights reserved.
//

#ifndef ApplicationTest_CGDefine_h
#define ApplicationTest_CGDefine_h

//定义视图的位置和大小

#define SCREEN_WIDTH        880
#define SCREEN_HEIGHT       440

#define TITLEVIEW_X         0
#define TITLEVIEW_Y         0
#define TITLEVIEW_WIDTH     SCREEN_WIDTH - 2*TITLEVIEW_X
#define TITLEVIEW_HEIGHT    70

#define BOTTOMVIEW_X         0
#define BOTTOMVIEW_Y         SCREEN_HEIGHT - 30
#define BOTTOMVIEW_WIDTH     SCREEN_WIDTH
#define BOTTOMVIEW_HEIGHT    30

#define TABVIEW_X           20
#define TABVIEW_Y           20 + TITLEVIEW_HEIGHT
#define TABVIEW_WIDTH       540
#define TABVIEW_HEIGHT      185

#define TABLEVIEW1_X        0
#define TABLEVIEW1_Y        0

#define TABLEVIEW1_WIDTH    TABVIEW_WIDTH
#define TABLEVIEW1_HEIGHT   185

#define TABLEVIEW2_X        0
#define TABLEVIEW2_Y        15 + TABLEVIEW1_HEIGHT
#define TABLEVIEW2_WIDTH    TABVIEW_WIDTH
#define TABLEVIEW2_HEIGHT   135


#define FIXTURESTATUSVIEW_X      20
#define FIXTURESTATUSVIEW_Y    SCREEN_HEIGHT - FIXTURESTATUSVIEW_HEIGHT - 38
#define FIXTURESTATUSVIEW_WIDTH     TABVIEW_WIDTH
#define FIXTURESTATUSVIEW_HEIGHT    26

#define CONFIGLABEL1_WIDTH    100
#define CONFIGLABEL1_HEIGHT   25

#define CONFIGLABEL1_X        580
#define CONFIGLABEL1_Y        90
#define CONFIGLABEL2_X        540
#define CONFIGLABEL2_Y        860

#define CONFIGEDIT_WIDTH     260
#define CONFIGEDIT_HEIGHT    25

#define CONFIGEDIT1_X    580
#define CONFIGEDIT1_Y    120
#define CONFIGEDIT2_X    860
#define CONFIGEDIT2_Y    270

#define ASNLABEL1_WIDTH    100
#define ASNLABEL1_HEIGHT   25

#define ASNLABEL1_X        580
#define ASNLABEL1_Y        150
#define ASNLABEL2_X        540
#define ASNLABEL2_Y        860

#define ASNEDIT_WIDTH     260
#define ASNEDIT_HEIGHT    25

#define ASNEDIT1_X    580
#define ASNEDIT1_Y    180
#define ASNEDIT2_X    860
#define ASNEDIT2_Y    270

#define FSNLABEL_WIDTH     50
#define FSNLABEL_HEIGHT    25

#define FSNLABEL1_X    580
#define FSNLABEL1_Y    212
#define FSNLABEL2_X    860
#define FSNLABEL2_Y    300

#define FSNEDIT_WIDTH     250
#define FSNEDIT_HEIGHT    25

#define FSNEDIT1_X    620
#define FSNEDIT1_Y    212
#define FSNEDIT2_X    900
#define FSNEDIT2_Y    300

#define STATUSVIEW_WIDTH     140
#define STATUSVIEW_HEIGHT    38

#define STATUSVIEW1_X    580
#define STATUSVIEW1_Y    240
#define STATUSVIEW2_X    860
#define STATUSVIEW2_Y    330

#define TIMEVIEW_WIDTH     100
#define TIMEVIEW_HEIGHT    36

#define TIMEVIEW1_X    730
#define TIMEVIEW1_Y    250
#define TIMEVIEW2_X    1050
#define TIMEVIEW2_Y    340

#define SFCTEXTVIEW_X    580
#define SFCTEXTVIEW_Y    300
#define SFCTEXTVIEW_WIDTH     210
#define SFCTEXTVIEW_HEIGHT    300

#define STATISTICSVIEW_X         20
#define STATISTICSVIEW_Y         SCREEN_HEIGHT - STATISTICSVIEW_HEIGHT
#define STATISTICSVIEW_WIDTH     TABVIEW_WIDTH
#define STATISTICSVIEW_HEIGHT    60

#endif
