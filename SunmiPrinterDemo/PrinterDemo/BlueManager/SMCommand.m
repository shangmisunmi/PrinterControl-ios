//
//  SMCommand.m
//  PrinterDemo
//
//  Created by SM1441 on 2021/12/13.
//  Copyright © 2021 mark. All rights reserved.
//

#import "SMCommand.h"



@implementation SMCommand

//UTF8
+ (NSData *)textTypeUTF8 {
    Byte byteArr[8] = {0x1D, 0x28 ,0x45, 0x03, 0x00, 0x06, 0x03, 0x01};
    NSData *data = [NSData dataWithBytes:byteArr length:8];
    return data;
}


+ (NSData *)formatWithTextType:(NSInteger)textType {
    Byte byteArr[16] = {0x1D, 0x28 ,0x45, 0x03, 0x00, 0x06, 0x03, 0x00, 0x1D, 0x28 ,0x45, 0x03, 0x00, 0x06, 0x01};
    if (textType == 1) {
        byteArr[15] = 0x01; //BIG5
    }
    else if (textType == 2) {
        byteArr[15] = 0x0B; //Shift JIS
    }
    else  {
        byteArr[15] = 0x00; //GB 18030
    }
    NSData *data = [NSData dataWithBytes:byteArr length:16];
    return data;
}

+ (NSData *)openCashBox {
    Byte byteArr[5] = {0x1b, 0x70, 0x00, 0x32, 0x32};
    NSData *data = [NSData dataWithBytes:byteArr length:5];
    return data;
}

+ (NSData *)printFirst {
    Byte byteArr[10] = {0x1D, 0x28, 0x54, 0x01, 0x00, 0x02};
    NSData *data     = [NSData dataWithBytes:byteArr length:6];
    return data;
}

+ (NSData *)printResult {
    Byte byteArr[10] = {0x1D, 0x28, 0x54, 0x05, 0x00, 0x03, 0xd1, 0xd2, 0xd3, 0xd4};
    NSData *data     = [NSData dataWithBytes:byteArr length:10];
    return data;
}

@end
