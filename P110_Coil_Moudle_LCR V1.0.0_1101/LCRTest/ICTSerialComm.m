//
//  ICTSerialComm.m
//  TestSerialComm
//
//  Created by Jason liang on 16-1-26.
//  Copyright (c) 2016年 Jason liang. All rights reserved.
//

#import "ICTSerialComm.h"

#import <IOKit/IOKitLib.h>
#import <IOKit/serial/IOSerialKeys.h>

#define BUFFER_SIZE 1024

NSString* const MACOS_COMM_RECVSIGNAL_CHAR = @"MACOS_COMM_RECVSIGNAL_CHAR";

@implementation ICTSerialComm

@synthesize delay = _delay;

- (id)init
{
    self = [super init] ;
    
    if (self) {
        _triggerThread = nil;
        _bWaitingSignal = NO;
        //_bIsOpen = NO;
        _isOpen = NO;
        _conditionSerial = [[NSCondition alloc] init];
        
        ////
        _delay = 0.2f;
    }
    return self ;
}

//- (void)dealloc
//{
//    [self close];
//    [super dealloc];
//}

-(int)findUSBDevices:(NSMutableArray *)array
{
    status = viFindRsrc (defaultRM, "USB[0-9]*::?*INSTR", &findList, &numInstrs, instrDescriptor);
    if (status < VI_SUCCESS)
    {
        printf ("An error occurred while finding resources.\nHit enter to continue.");
        viClose (defaultRM);
        return status;
    }
    
    printf("%zd instruments resources found:\n\n", numInstrs);
    printf("%s \n",instrDescriptor);
    
    return numInstrs;
}

    
- (BOOL)open:(NSString *)portName BaudRate:(enum BaudRate)baudRate
                                 DataBits:(enum DataBits)dataBits
                                  StopBit:(enum StopBit)stopBit
                                   Parity:(enum Parity)parity
                              FlowControl:(enum FlowControl)flowControl
{
    if (portName == nil)
        return NO;
    
    //filedesc configure
	_ifileDesc = open([portName cStringUsingEncoding:NSASCIIStringEncoding], O_RDWR|O_NOCTTY|O_NDELAY|O_EXLOCK) ;
    
	if (_ifileDesc > 0)
	{
        tcgetattr(_ifileDesc, &_serialOption) ;
		_serialOption.c_cc[VMIN] = 0;
		_serialOption.c_cc[VTIME] = 1;
		_serialOption.c_cflag |= (CLOCAL|CREAD);
        
        //set define value
	    [self setBaudRate:baudRate];
		[self setParity:parity];
		[self setStopBit:stopBit];
		[self setDataBit:dataBits];
		[self setFlowControl:flowControl];
        
        if (tcsetattr(_ifileDesc, TCSANOW, &_serialOption) != 0)
            return NO;
        
        //_bIsOpen = YES;
        _isOpen = YES;
        
        if (_bWaitingSignal)
        {
            _triggerThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(triggerHandleThread)
                                                       object:nil];
            [_triggerThread start];
        }
        
        return YES;
    }
    
    return NO;
}

-(BOOL)open:(NSString *)session
{
    /* Now we will open a session to the instrument we just found. */
    if ([session length] > 0) {
        /* First we will need to open the default resource manager. */
        status = viOpenDefaultRM (&defaultRM);
        if (status < VI_SUCCESS)
        {
            printf("Could not open a session to the VISA Resource Manager!\n");
            //exit (EXIT_FAILURE);
        }
        
        status = viOpen (defaultRM, [session cStringUsingEncoding:NSASCIIStringEncoding], VI_NULL, VI_NULL, &instr);
    } else {
        status = viOpen (defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
    }
    //_fOpen = YES;
    _isOpen = YES;
    //status = viOpen (defaultRM, "USB0::0x0699::0x0406::C023705::INSTR", VI_NULL, VI_NULL, &instr);
    if (status < VI_SUCCESS)
    {
        printf ("An error occurred opening a session to %s\n",instrDescriptor);
        //_fOpen = NO;
        _isOpen = NO;
        viClose (defaultRM);
        return NO;
    }
    
    /*
     * Set timeout value to 5000 milliseconds (5 seconds).
     */
    status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 5000);
    
    return YES;
}

    
- (void)close
{
    if (_ifileDesc) {
        close(_ifileDesc);
        _ifileDesc = -1;
    }
    
    //_bIsOpen = NO;
    _isOpen = NO;
    _bWaitingSignal = NO;
    
    if (_triggerThread != nil) {
        [_triggerThread cancel];
        _triggerThread = nil;
    }
    
    //////////////visa////////////
    //_fOpen = NO;
    
    if (instr) {
        viClose (instr);
    }
    
    if (findList) {
        viClose(findList);
    }
    
    if (defaultRM) {
        viClose (defaultRM);
    }

}

- (BOOL)Open
{
    //return _bIsOpen;
    return _isOpen;
}
    
// Replace non-printable characters in str with '\'-escaped equivalents.
// This function is used for convenient logging of data traffic.
static char *logString(char *str)
{
    static char     buf[BUFFER_SIZE];
    char            *ptr = buf;
    int             i;
    
    memset(buf, 0, BUFFER_SIZE);
    
    *ptr = '\n';
    
    while (*str) {
        if (isprint(*str)) {
            *ptr++ = *str++;
        }
        else {
            switch(*str) {
                case ' ':
                *ptr++ = *str;
                break;
                
                case 27:
                *ptr++ = '\\';
                *ptr++ = 'e';
                break;
                
                case '\t':
                *ptr++ = '\\';
                *ptr++ = 't';
                break;
                
                case '\n':
                *ptr++ = '\\';
                *ptr++ = 'n';
                break;
                
                case '\r':
                *ptr++ = '\\';
                *ptr++ = 'r';
                break;
                
                default:
                i = *str;
                (void)sprintf(ptr, "\\%03o", i);
                ptr += 4;
                break;
            }
            
            str++;
        }
        
        *ptr = '\r';
    }
    
    return buf;
}
    
- (BOOL)write:(NSString*)strCommand type:(NSString*)strPortType
{
    if ([strPortType isEqualToString:@"serial"]) {
        [_conditionSerial lock];
        char *charCommand = (char *)[strCommand cStringUsingEncoding:NSASCIIStringEncoding];
        ssize_t numBytes = write(_ifileDesc, logString(charCommand), strlen(logString(charCommand)));
        
        if (numBytes == -1) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
            [_conditionSerial unlock];
            
            return NO;
        } else {
            printf("Wrote %ld bytes \"%s\"\n", numBytes, charCommand);
        }
        
        [_conditionSerial unlock];
    } else if ([strPortType isEqualToString:@"visa"]) {
        char stringinput[255];
        ViUInt32 writeCount;
        
        //[NSThread sleepForTimeInterval:_delay];
        NSString *strTemp = [NSString stringWithString:strCommand];
        strcpy(stringinput, [strTemp cStringUsingEncoding:NSASCIIStringEncoding]);
        status = viWrite (instr, (ViBuf)stringinput, (ViUInt32)strlen(stringinput), &writeCount);
        
        if (status < VI_SUCCESS)
        {
            NSLog(@"Write command fail!!! command: %@",strTemp);
            
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)read:(NSString **)strData type:(NSString*)strPortType
{
    if ([strPortType isEqualToString:@"serial"]) {
        NSTimeInterval startTime = 0.0f;
        NSTimeInterval endTime = 0.0f;
        long wordsRead = -1;
        char buffer[BUFFER_SIZE];
        NSString *strReceived = [[NSString alloc] init];
        startTime = [NSDate timeIntervalSinceReferenceDate];
        
        [_conditionSerial lock];
        
        while ((endTime - startTime) < 0.2f) {
            int count = 0;
            memset(buffer, 0, BUFFER_SIZE);
            wordsRead = read(_ifileDesc, buffer, BUFFER_SIZE);
            
            if (wordsRead > 0) {
                count ++;
                NSString *tmp = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                strReceived = [strReceived stringByAppendingString:tmp];
            } else {
                if (count == 3) {
                    break;
                }
                //break;
            }
            usleep(30000); //delay 60 ms
            endTime = [NSDate timeIntervalSinceReferenceDate];
        }
        [_conditionSerial unlock];
        
        if (!([strReceived length] > 0)) {
            *strData = @"";
            
            return NO;
        } else {
            *strData = strReceived;
        }
    } else if ([strPortType isEqualToString:@"visa"]) {
        unsigned char buffer1[1024];
        ViUInt32 retCount;
        memset(buffer1, 0, 1024);
        
        [NSThread sleepForTimeInterval:_delay];
        status = viRead (instr, buffer1, 1024, &retCount);

        if (status < VI_SUCCESS)
        {
            NSLog(@"read command fail!!!");
            
            return NO;
        }
        
        NSLog(@"Query Data: %s", buffer1);
        //float value = [[NSString stringWithFormat:@"%s", buffer1] floatValue];
        //*strData = [NSString stringWithFormat:@"%f",value];
        *strData = [NSString stringWithFormat:@"%s",buffer1];
    }
    
    return YES;
}
    
- (BOOL)query:(NSString *)strCommand ret:(NSString **)strData type:(NSString*)strPortType
{
    char *charCommand = (char *)[strCommand cStringUsingEncoding:NSASCIIStringEncoding];
    [_conditionSerial lock];
    ssize_t numBytes = write(_ifileDesc, logString(charCommand), strlen(logString(charCommand)));
    
    NSTimeInterval startTime = 0.0f;
    NSTimeInterval endTime = 0.0f;
    long wordsRead = -1;
    char buffer[BUFFER_SIZE];
    NSString *strReceived = [[NSString alloc] init];
    startTime = [NSDate timeIntervalSinceReferenceDate];
    
    /////////////////////visa///////////////////////
    unsigned char buffer1[255];
    char stringinput[255];
    ViUInt32 writeCount;
    ViUInt32 retCount;
    
    NSString *strTemp = [NSString stringWithFormat:@"%@\n", strCommand];
    strcpy(stringinput,[strTemp cStringUsingEncoding:NSASCIIStringEncoding]);
    status = viWrite (instr, (ViBuf)stringinput, (ViUInt32)strlen(stringinput), &writeCount);
    
    memset(buffer, 0, 255);
    status = viRead(instr, buffer1, 255, &retCount);
    
    if ([strPortType isEqualToString:@"serial"]) {
        if (numBytes == -1) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
            [_conditionSerial unlock];
            return NO;
        }
        else {
            printf("Wrote %ld bytes \"%s\"\n", numBytes, charCommand);
        }
        
       
        
        while ((endTime - startTime) < 0.2f) {
            memset(buffer, 0, BUFFER_SIZE);
            wordsRead = read(_ifileDesc, buffer, BUFFER_SIZE);
            
            if (wordsRead > 0) {
                NSString *tmp = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                strReceived = [strReceived stringByAppendingString:tmp];
            }
            
            usleep(10000); //delay 10 ms
            endTime = [NSDate timeIntervalSinceReferenceDate];
        }
        NSLog(@"Time Out %@", [NSString stringWithFormat:@"%f", (endTime - startTime)]);
        [_conditionSerial unlock];
        if (!([strReceived length] > 0)) {
            *strData = @"";
            return NO;
        } else {
            *strData = strReceived;
        }

    } else if ([strPortType isEqualToString:@"visa"]) {
        if (status < VI_SUCCESS)
        {
            NSLog(@"Write command fail!!! command: %@",strTemp);
            return NO;
        }
        
        [NSThread sleepForTimeInterval:_delay];
        
        if (status < VI_SUCCESS)
        {
            NSLog(@"Read command fail!!! command: %@", strTemp);
            return NO;
        }
        NSLog(@"Query Data: %s", buffer);
        
//        extern NSString *_strFrom;
//        extern NSString *_strTo;
        
        NSString *tmp = [[NSString alloc] initWithUTF8String:(char *)buffer];
       // NSString *result = [self getData:tmp startSet:_strFrom endSet:_strTo];
        
        float value = [[NSString stringWithFormat:@"%@", tmp] floatValue];
        *strData = [NSString stringWithFormat:@"%f", fabs(value)];
    }
    
//    if ([strReceived length] > 0) {
//        *strData = strReceived;
//        return YES;
//    } else {
//        *strData = @"";
//        return NO;
//    }
    return YES;
}

#pragma mark - set
- (void)setBaudRate:(enum BaudRate)baudRate
{
    switch (baudRate) {
        case BAUDRATE_9600:
            cfsetispeed(&_serialOption, B9600);
            cfsetospeed(&_serialOption, B9600);
            break;
        case BAUDRATE_19200:
            cfsetispeed(&_serialOption, B19200);
            cfsetospeed(&_serialOption, B19200);
            break;
        case BAUDRATE_38400:
            cfsetispeed(&_serialOption, B38400);
            cfsetospeed(&_serialOption, B38400);
            break;
        case BAUDRATE_76800:
            cfsetispeed(&_serialOption, B76800);
            cfsetospeed(&_serialOption, B76800);
            break;
        case BAUDRATE_115200:
            cfsetispeed(&_serialOption, B115200);
            cfsetospeed(&_serialOption, B115200);
            break;
        case BAUDRATE_230400:
            cfsetispeed(&_serialOption, B230400);
            cfsetospeed(&_serialOption, B230400);
            break;
        default:
            break;
    }
    return;
}

- (void)setDataBit:(enum DataBits)dataBits
{
    switch (dataBits) {
        case DATA_BITS_5:
            _serialOption.c_cflag |= CS5;
            break;
        case DATA_BITS_6:
            _serialOption.c_cflag |= CS6;
            break;
        case DATA_BITS_7:
            _serialOption.c_cflag |= CS7;
            break;
        case DATA_BITS_8:
            _serialOption.c_cflag |= CS8;
            break;
        default:
            break;
    }
    return;
}
    
- (void)setParity:(enum Parity)parity
{
    switch (parity) {
        case PARITY_EVEN:
            _serialOption.c_cflag |= PARENB;
            _serialOption.c_cflag &= ~PARODD;
            break;
        case PARITY_ODD:
            _serialOption.c_cflag |= PARENB;
            _serialOption.c_cflag |= PARODD;
            break;
        case PARITY_NONE:
            _serialOption.c_cflag &= ~PARENB;
            break;
        default:
            break;
    }
    return;
}
    
- (void)setStopBit:(enum StopBit)stopBit
{
    switch (stopBit) {
        case STOP_BITS_1:
            _serialOption.c_cflag |= CSTOPB;
            break;
        case STOP_BITS_2:
            _serialOption.c_cflag &= ~CSTOPB;
            break;
        default:
            break;
    }	
    return;
}
    
    
- (void)setFlowControl:(enum FlowControl)flowControl
{
    switch (flowControl) {
        case FLOW_CONTROL_HANDWARE:
        case FLOW_CONTROL_SOFTWARE:
        case FLOW_CONTROL_NONE:	
            _serialOption.c_cflag &= ~CSTOP;
            break;
        default:
            break;
    }	
    return;
}
    
+ (NSArray*)scanPort
{
    io_iterator_t	serialPortIterator;
    CFMutableDictionaryRef classToMatch;
    io_object_t		serialService;
    kern_return_t	kernResult;
    //char			bsdPath[BUFFER_SIZE];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init] ;
    // find serial serial port iterator
    classToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    
    if(classToMatch == NULL){
        //NSLog(@"IOServiceMatching return null dictionary.");
    } else {
        CFDictionarySetValue(classToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDRS232Type));
    }
    
    kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classToMatch, &serialPortIterator);
    
    if(KERN_SUCCESS != kernResult){
        //NSLog(@"IOServiceGetMatchingServices returned %d \n", kernResult);
    }
    // get device path
    while ((serialService = IOIteratorNext(serialPortIterator))) {
        CFTypeRef	bsdPathAsCFString;
        
        bsdPathAsCFString = IORegistryEntryCreateCFProperty(serialService,
                                                            CFSTR(kIODialinDeviceKey),
                                                            kCFAllocatorDefault,
                                                            0);
        if (bsdPathAsCFString) {
            NSString *str = [NSString stringWithFormat:@"%@", bsdPathAsCFString];
            
            if ([str rangeOfString:@"usbserial"].length > 0) {
                [mutableArray addObject:str];
            }
            CFRelease(bsdPathAsCFString);
        }
    }
    
    return mutableArray;
}
    
#pragma mark - trigger
- (void)triggerHandleThread
{
    long wordsRead = 0;
    char buffer[BUFFER_SIZE];
    NSString *strReceived = [[NSString alloc] init];

    @autoreleasepool {
        while (_isOpen) {
                while (_bWaitingSignal) {
                    memset(buffer, 0, BUFFER_SIZE);
                    usleep(10000); //delay 10 ms
                    wordsRead = read(_ifileDesc, buffer, BUFFER_SIZE);

                    if (wordsRead > 0) {
                        NSString *tmp = [NSString stringWithFormat:@"%s", buffer];
                        strReceived = [strReceived stringByAppendingString:tmp];
                        NSLog(@"triggerHandleThread strReceived = %@", strReceived);
                        if ([strReceived rangeOfString:@"A"].length > 0) {
                            NSLog(@"strReceived = %@", strReceived);
                            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] initWithCapacity:2];
                            [newdict setObject:strReceived forKey:@"result"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:MACOS_COMM_RECVSIGNAL_CHAR
                                                                                object:self
                                                                              userInfo:newdict];
                            //[newdict release];
                            strReceived = @"";
//                            _bWaitingSignal = NO;
                        }
                    }

            }
        }
    }
}

#pragma mark - cut off

- (NSString *)getData:(NSString *)fileContent startSet:(NSString *)strStart endSet:(NSString *)strEnd
{
    NSRange rangeStr;
    NSUInteger iPosStr;
    
    if ([strStart length] == 0) {
        iPosStr = 0;
    } else {
        rangeStr = [fileContent rangeOfString:strStart];
        iPosStr = (rangeStr.location + rangeStr.length);
    }
    
    fileContent = [fileContent substringFromIndex:iPosStr];
    
    NSRange rangeStrEnd;
    NSUInteger iLengthStr;
    
    if ([strEnd length]== 0) {
        iLengthStr = [fileContent length];
    } else {
        rangeStrEnd = [fileContent rangeOfString:strEnd];
        iLengthStr = rangeStrEnd.location;
    }
    
    NSString *strRet = [fileContent substringWithRange:NSMakeRange(0, iLengthStr)];
    
    return strRet;
}

@end
