//
//  ICTSerialComm.h
//  TestSerialComm
//
//  Created by Jason liang on 16-1-26.
//  Copyright (c) 2016年 Jason liang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <VISA/VISA.h>
#include <termios.h>

//baudrate default
enum BaudRate
{
    BAUDRATE_9600   = 9600,
    BAUDRATE_19200  = 19200,
    BAUDRATE_38400  = 38400,
    BAUDRATE_76800  = 76800,
    BAUDRATE_115200 = 115200,
    BAUDRATE_230400 = 230400,
    BAUDRATE_DEFAULT= BAUDRATE_115200,
};

//data bit defined
enum DataBits
{
    DATA_BITS_5,
    DATA_BITS_6,
    DATA_BITS_7,
    DATA_BITS_8,
    DATA_BITS_DEFAULT = DATA_BITS_8,
};

//parity bit define
enum Parity
{
    PARITY_EVEN,
    PARITY_ODD,
    PARITY_NONE,
    PARITY_DEFAULT = PARITY_NONE,
};

//stop bit define
enum StopBit
{
    STOP_BITS_1,
    STOP_BITS_2,
    STOP_BITS_DEFAULT = STOP_BITS_1,
};

//flow control
enum FlowControl
{
    FLOW_CONTROL_HANDWARE,
    FLOW_CONTROL_SOFTWARE,
    FLOW_CONTROL_NONE,
    FLOW_CONTROL_DEFAULT = FLOW_CONTROL_NONE ,
};

@interface ICTSerialComm : NSObject
{
    int _ifileDesc;
    struct termios _serialOption; //file description structure
    
   // BOOL _bIsOpen;
    
    NSThread *_triggerThread;
    BOOL _bWaitingSignal;
    NSCondition *_conditionSerial;
    
    /////////////////visa////////////////
    char instrDescriptor[VI_FIND_BUFLEN];
    ViUInt32 numInstrs;
    ViFindList findList;
    ViSession defaultRM, instr;
    ViStatus status;
    float _delay;
    BOOL _fOpen;
    

}

@property BOOL isOpen;
@property (assign, nonatomic) BOOL bWaitingSignal;
@property (nonatomic, assign) float delay;

+ (NSArray*)scanPort;

- (BOOL)Open;
- (void)close;

- (int)findUSBDevices:(NSMutableArray *)array;
- (BOOL)open:(NSString *)session;
- (BOOL)open:(NSString *)session BaudRate:(enum BaudRate)baudRate
                                 DataBits:(enum DataBits)dataBits
                                  StopBit:(enum StopBit)stopBit
                                   Parity:(enum Parity)parity
                              FlowControl:(enum FlowControl)flowControl;

- (BOOL)write:(NSString*)strCommand type:(NSString*)strPortType;
- (BOOL)read:(NSString **)strData type:(NSString*)strPortType;
- (BOOL)query:(NSString *)strCommand ret:(NSString **)strData type:(NSString*)strPortType;

@end
