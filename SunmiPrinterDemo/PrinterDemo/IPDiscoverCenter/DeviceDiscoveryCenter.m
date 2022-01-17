//
//  DeviceDiscoveryCenter.h
//  router
//
//  Created by SUNMI on 2018/8/14.
//  Copyright © 2021年 Wireless Department. All rights reserved.
//

#import "DeviceDiscoveryCenter.h"
#import "SunmiHeader.h"
#import "GCDAsyncUdpSocket.h"
// 获取mac地址需要导入的库
#import "sys/utsname.h"
#import "GCDAsyncSocket.h"
#import <AdSupport/AdSupport.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "BlueModel.h"
#import "SMProgressHUD.h"

#define SMHOST_PORT         17899
#define BROADCAST_IP        @"224.0.0.1"

@interface DeviceDiscoveryCenter()<GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate>
{
    NSString *ipString;
}
@property (nonatomic, strong) GCDAsyncUdpSocket      *udpSocketClient;
@property (nonatomic, strong) NSTimer                  *broadcastTimer;
@property (nonatomic, strong) NSMutableArray         *detectedIpArray;
@property (nonatomic, strong) NSThread               *timerThread;
@property (nonatomic, copy) NSDictionary           *connectingRouterDeviceInfo;//当前已连接的路由器设备
@property (nonatomic, copy) NSDictionary           *connectingIPCDeviceInfo;   //当前已连接的IPC设备
@property (nonatomic, copy) void(^resultBlcok)(NSArray *resultDict);
@property (nonatomic, strong) dispatch_source_t timer; //定时器
@property (nonatomic, strong) GCDAsyncSocket *tcpSocketConnect;
@property (nonatomic, copy)  IPConnectDeviceBlock connectionBlock;

@end

@implementation DeviceDiscoveryCenter

+ (instancetype)sharedManager {
    static DeviceDiscoveryCenter *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _detectedIpArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark ------- custom

// UDP初始化
- (void)preparationForUdpBroadcast {
    if (self.udpSocketClient) {
        [self.udpSocketClient close];
        self.udpSocketClient = nil;
    }
    _udpSocketClient = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //要接收信息，必须绑定端口、然后等待接接收回复信息
    NSError *error = nil;
    BOOL success = NO;
    success = [_udpSocketClient bindToPort:SMHOST_PORT error:&error];
    if (error) {
        NSLog(@"bindToPort - error: %@", error);
        return;
    }
    if (success == NO) {
        NSLog(@"bindToPort - fail");
        return;
    }
    success = [_udpSocketClient beginReceiving:&error];
    if (error) {
        NSLog(@"beginReceiving - error: %@", error);
        return;
    }
    if (success == NO) {
        NSLog(@"beginReceiving - fail");
        return;
    }
    success = [_udpSocketClient enableBroadcast:YES error:&error];
    if (error) {
        NSLog(@"enableBroadcast - error: %@", error);
        return;
    }
    if (success == NO) {
        NSLog(@"enableBroadcast - fail");
        return;
    }
}

// MARK: 停止
- (void)stopSearching {
    [_broadcastTimer invalidate];
    _broadcastTimer = nil;
    _timerThread = nil;
    [self.udpSocketClient close];
    self.udpSocketClient = nil;
    [self.detectedIpArray removeAllObjects];
}

- (void)disConnectIPService {
    self.connectionBlock = nil;
    [self.tcpSocketConnect disconnect];
    self.tcpSocketConnect.delegate = nil;
    self.tcpSocketConnect = nil;
}

- (BOOL)IsConnectedIPService {
    return [self.tcpSocketConnect isConnected];
}

// MARK: 发送
- (void)broadcastToDetectDevice {
    ipString = [self getIPAddress];
    Byte byteArr[60] = {0x1D, 0x28 ,0x45, 0x03};
    NSData *data = [NSData dataWithBytes:byteArr length:60];
    
    NSError *error = nil;
    BOOL success = NO;
    NSLog(@"去发送UDP广播~~~");
    [_udpSocketClient sendData:data toHost:BROADCAST_IP port:SMHOST_PORT withTimeout:-1 tag:4];
    //发送之后，设置开始接收，否则再次初始化此类后，会因为端口被占用收不到信息
    success = [_udpSocketClient beginReceiving:&error];
    if (error) {
        NSLog(@"beginReceiving - error: %@", error);
        return;
    }
    if (success == NO) {
        NSLog(@"beginReceiving - fail");
        return;
    }
}

//清除上一次发现设备的记录
- (void)clearDetectedData {
    if(_detectedIpArray.count) {
        [_detectedIpArray removeAllObjects];
    }
}

- (void)startSearchDeviceWithResultBlock:(void(^)(NSArray *deviceModel))resultBlock {
    __weak typeof(self)weakSelf = self;
    [self clearDetectedData];
    [self preparationForUdpBroadcast];
    if (self.timer == nil) {
        __block int second = 0;
        dispatch_queue_t queue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, interval, 1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (second < 3) {
                    [weakSelf broadcastToDetectDevice];
                    second ++;
                } else {
                    [self closeTime];
                    if (weakSelf.detectedIpArray.count == 0) {
                        self.connectingRouterDeviceInfo = nil;
                        self.connectingIPCDeviceInfo = nil;
                    }
                    
                    [weakSelf stopSearching];
                }
            });
        });
        dispatch_resume(self.timer);
    }
    self.resultBlcok = resultBlock;
}

// MARK: 关闭刷新
- (void)closeTime {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"UDP 连接成功 --- %@", address);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"%ld tag 发送数据成功", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"UDP 发送数据失败: tag=%ld, error: %@", tag, error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error {
    NSLog(@"UDP 连接失败：%@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSLog(@"接受数据的回调");
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    if ([ip isEqualToString:ipString]) {
        return;
    }
    
//    NSData *headerData = [data subdataWithRange:NSMakeRange(0, 16)];
//    NSString *str = [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding];
    
    NSData *mid   = [data subdataWithRange:NSMakeRange(16, 16)];
    NSString *str2 = [[NSString alloc] initWithData:mid encoding:NSUTF8StringEncoding];

    NSData *final   = [data subdataWithRange:NSMakeRange(32, 24)];
    NSString *str3 = [[NSString alloc] initWithData:final encoding:NSUTF8StringEncoding];
    
    BlueModel *model = [[BlueModel alloc] init];
    model.deviceIP = ip;
    model.model = str2;
    model.deviceName = str3;
    model.sn    = str3;
    
    BOOL isExist = NO;
    for (BlueModel * m in self.detectedIpArray) {
        if ([m.sn isEqualToString:model.sn]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist && str3.length > 0 && str2.length > 0) {
        [self.detectedIpArray addObject:model];
    }
    if (self.resultBlcok)  self.resultBlcok([self.detectedIpArray copy]);
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"关闭失败: %@", error);
}

// MARK: 通过 IP 连接设备
- (void)connectSocketWithIP:(NSString *)ip completeBlock:(IPConnectDeviceBlock)completeBlock {
    self.connectionBlock = completeBlock;
    [self.tcpSocketConnect connectToHost:ip onPort:9100 error:nil];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    NSLog(@"TCP 连接到 host: %@ port: %d", host, port);
    if (self.connectionBlock) {
        self.connectionBlock([NSError errorWithDomain:@"TCP 连接成功!" code:401 userInfo:nil]);
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"断开 socket 连接: %@", err);
    if (self.connectionBlock) {
        self.connectionBlock([NSError errorWithDomain:@"TCP 断开连接" code:400 userInfo:nil]);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"接收到 tag = %ld : %ld 长度的数据", tag, data.length);
    if (tag == PrintStateCode) {
        Byte byteArr[10] = {0x1D, 0x28, 0x54, 0x05, 0x00, 0x03};
        NSMutableData *mutableData = [NSMutableData dataWithBytes:byteArr length:6];
        [mutableData appendData:data];
        [self controlDevicePrintingData:[mutableData copy]];
        [self readDataFromSocketWithTag:102];
    }
    if (tag == 102) {
        NSString *str = [self convertDataToHexStr: data];
        [SMProgressHUD toastWithText:SMLocalizeString(str)];
    }
}

// MARK： 写数据
- (void)controlDevicePrintingData:(NSData *)ipData {
    [self.tcpSocketConnect writeData:ipData withTimeout:10 tag:100];
}

// MARK: 读数据
-(void)readDataFromSocketWithTag: (NSInteger)tag {
    [self.tcpSocketConnect readDataWithTimeout:-1 tag:tag];
}

#pragma mark - getter

- (GCDAsyncSocket *)tcpSocketConnect {
    if (!_tcpSocketConnect) {
        _tcpSocketConnect = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return _tcpSocketConnect;
}

#pragma mark - tools

// data 转 16 进制
- (NSString *)convertDataToHexStr:(NSData *)data{
    if (!self || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

// 获取设备IP地址
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // 检索当前接口,在成功时,返回0
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // 循环链表的接口
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // 检查接口是否en0 wifi连接在iPhone上
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // 得到NSString从C字符串
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // 释放内存
    freeifaddrs(interfaces);
    return address;
}

@end
