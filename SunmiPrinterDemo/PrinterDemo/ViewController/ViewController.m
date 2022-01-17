//
//  ViewController.m
//  PrinterDemo
//
//  Created by mark on 2020/6/18.
//  Copyright © 2020 mark. All rights reserved.
//

#import "ViewController.h"
#import "SunmiHeader.h"
#import "DeviceListViewController.h"
#import "UIView+Frame.h"
#import "ContentTableViewCell.h"
#import "BlueModel.h"
#import "SNBluetooth.h"
#import "SMProgressHUD.h"
#import "TextCodeView.h"
#import "SMCommand.h"
#import "DeviceDiscoveryCenter.h"
#import "PrinterImage.h"
#define MAX_DATA_LEN 20

@interface ViewController ()<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)UITableView *listTable;
@property(nonatomic, strong)BlueModel *currentModel;
@property(nonatomic, strong)NSMutableArray *dataSource;
@property(nonatomic, strong)NSString *contentText;
@property(nonatomic, strong)NSArray <NSString *> *textCodeArray;
@property(nonatomic, assign)NSInteger selectedIndex;
@property(nonatomic, strong)NSString *codeType;
@property (nonatomic, assign) PrintConnectType currentPrintType;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:SMLocalizeString(@"Printer")];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setup];
}

- (void)setup {
    self.selectedIndex = -1;
    self.textCodeArray = @[@"UTF8", @"BIG5", @"Shift JIS", @"GB 18030"];
    [self.view addSubview:self.listTable];

    [[SNBluetooth sharedInstance] isReady];
    
    __weak typeof(self)weakSelf = self;
    [[SNBluetooth sharedInstance] deviceDisConnectWithBlock:^(CBPeripheral *device, NSError *err) {
        if ([self.currentModel.peripheral isEqual:device]) {
            weakSelf.currentModel = nil;
            weakSelf.selectedIndex = -1;
            weakSelf.codeType = nil;
            [weakSelf.listTable reloadData];
        }
    }];
}

// MARK: print image method
- (void)printBitmap {
    PrinterImage *printer = [[PrinterImage alloc]init];
    UIImage *image = [UIImage imageNamed:@"receipt.jpg"];
    NSData *data = [printer printWithImage:image maxWidth:576];
    [[DeviceDiscoveryCenter sharedManager] controlDevicePrintingData:data];
}

- (UITableView *)listTable {
    if (_listTable == nil) {
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, kAppNavHeight, self.view.width, self.view.height - kAppNavHeight) style:UITableViewStyleGrouped];
        _listTable.delegate = self;
        _listTable.dataSource = self;
        _listTable.backgroundColor = [UIColor whiteColor];
        _listTable.tableFooterView = [UIView new];
        _listTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _listTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _listTable.scrollIndicatorInsets = _listTable.contentInset;
        _listTable.backgroundColor = COLOR_F5;
        _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _listTable;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        }
        if (indexPath.section == 0) {
            if (self.currentModel != nil) {
                if (indexPath.row == 0) {
                    cell.textLabel.text = self.currentPrintType ? SMLocalizeString(@"Add Bluetooth printer") : self.currentModel.deviceName;
                    cell.detailTextLabel.text = self.currentPrintType ? @"" : SMLocalizeString(@"Connected");
                    cell.textLabel.textColor = self.currentPrintType ? [UIColor blueColor] : [UIColor blackColor];
                }
                else if (indexPath.row == 1) {
                    cell.textLabel.text = self.currentPrintType ? self.currentModel.sn : SMLocalizeString(@"Add IP printer");
                    cell.detailTextLabel.text = self.currentPrintType ? SMLocalizeString(@"Connected") : @"" ;
                    cell.textLabel.textColor = self.currentPrintType ? [UIColor blackColor] : [UIColor blueColor];
                }
            }
            else {
                cell.textLabel.text = indexPath.row == 0 ? SMLocalizeString(@"Add Bluetooth printer") : SMLocalizeString(@"Add IP printer");
                cell.textLabel.textColor = [UIColor blueColor];
                cell.detailTextLabel.text = @"";
            }
        }
        else {
            cell.textLabel.text = self.codeType.length == 0 ? @"" : self.codeType;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.text = self.codeType.length == 0 ? SMLocalizeString(@"Not selected") : SMLocalizeString(@"Connected");
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else {
        ContentTableViewCell *contentCell = [tableView dequeueReusableCellWithIdentifier:@"ContentTableViewCell"];
        if (contentCell == nil) {
            contentCell = [[ContentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContentTableViewCell"];
        }
        [contentCell setIsCanPrinter:self.currentModel];
        contentCell.cashdrawerBlock = ^{
            NSData *data = [SMCommand openCashBox];
            if (self.currentPrintType) {
                [[DeviceDiscoveryCenter sharedManager] controlDevicePrintingData:data];
            }
            else {
                [[SNBluetooth sharedInstance] writeCharacteristicWithServiceUUID:serviceString characteristicUUID:characteristicsString data:data];
            }
        };
        contentCell.printResultBlock = ^{
            NSData *data = [SMCommand printFirst];
            if (self.currentPrintType) {
                [[DeviceDiscoveryCenter sharedManager] controlDevicePrintingData:data];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5), dispatch_get_main_queue(), ^{
                    [[DeviceDiscoveryCenter sharedManager] readDataFromSocketWithTag:PrintStateCode];
                });
            }
        };
        contentCell.printImageBlock = ^{
            if (self.currentPrintType) {
                [self printBitmap];
            }
        };
        contentCell.printerBlock = ^(NSString * _Nonnull contentText) {
//            SNBluetooth *blueTooth = [SNBluetooth sharedInstance];
//            if (blueTooth.isConnection) {
                Byte byteArr[4] = {0x0a, 0x0a, 0x0a, 0x0a};
                NSData *data = nil;
                if (self.selectedIndex == 0) {
                    data = [contentText dataUsingEncoding:NSUTF8StringEncoding];
                }
                else {
                    NSStringEncoding code = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    if (self.selectedIndex == 1) {
                        code = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
                    }
                    else if (self.selectedIndex == 2) {
                        code = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingShiftJIS);
                    }
                    else if (self.selectedIndex == 3) {
                        code = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    }
                    data = [contentText dataUsingEncoding:code];
                }
                
                NSMutableData *sourceData = [NSMutableData dataWithData:data];
                [sourceData appendBytes:byteArr length:4];
                
                if (self.currentPrintType) {
                    [[DeviceDiscoveryCenter sharedManager] controlDevicePrintingData:sourceData];
                }
                else {
                    NSUInteger len = sourceData.length;
                    if (len > MAX_DATA_LEN) {
                        int packNum = (int)len/MAX_DATA_LEN;
                        int lastPackDataLen = (int)len%MAX_DATA_LEN;
                        for (int i = 0; i < packNum; i++) {
                            NSMutableData *subData = [NSMutableData dataWithData:[sourceData subdataWithRange:NSMakeRange(i*MAX_DATA_LEN, MAX_DATA_LEN)]];
                            [[SNBluetooth sharedInstance] writeCharacteristicWithServiceUUID:serviceString characteristicUUID:characteristicsString data:subData];
                        }
                        
                        if (lastPackDataLen > 0) {
                            NSMutableData *lastPackData = [NSMutableData dataWithData:[sourceData subdataWithRange:NSMakeRange(packNum*MAX_DATA_LEN, lastPackDataLen)]];
                            [[SNBluetooth sharedInstance] writeCharacteristicWithServiceUUID:serviceString characteristicUUID:characteristicsString data:lastPackData];
                        }
                        else {
    //                        NSData *lastData = [NSData dataWithBytes:byteArr length:1];
    //                        [[SNBluetooth sharedInstance] writeCharacteristicWithServiceUUID:serviceString characteristicUUID:characteristicsString data:lastData];
                        }
                    }
                    else{
                    
                        [[SNBluetooth sharedInstance] writeCharacteristicWithServiceUUID:serviceString characteristicUUID:characteristicsString data:sourceData];
                    }
                }
//            }
//            else {
//                [SMProgressHUD toastWithText:SMLocalizeString(@"Disconnected")];
//            }
        };
        return contentCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        self.currentModel = nil;
        if (indexPath.row == 0) {
            if ([SNBluetooth sharedInstance].isConnection) {
                [[SNBluetooth sharedInstance] disconnectionDevice];
            }
        }
        else if (indexPath.row == 1) {
            if ([[DeviceDiscoveryCenter sharedManager] IsConnectedIPService]) {
                [[DeviceDiscoveryCenter sharedManager] disConnectIPService];
            }
        }
        [self.listTable reloadData];
        [self addDeviceWithType:indexPath.row];
    }
    else if (indexPath.section == 1) {
        __weak typeof(self)weakSelf = self;
        if (self.currentModel != nil) {
            CGFloat viewHeight = 200 * SCREEN_POINT_375 + kSafeAreaBottom;
            TextCodeView *codeTypeView = [[TextCodeView alloc]initWithFrame:CGRectMake(0, kScreenHeight, self.view.width, viewHeight)];
            [codeTypeView setSelectedIndex:self.selectedIndex];
            codeTypeView.selectedBlock = ^(NSInteger selectedIndex) {
                if (selectedIndex == 0) {
                    NSData *data = [SMCommand textTypeUTF8];
                    if (self.currentPrintType) {
                        [[DeviceDiscoveryCenter sharedManager] controlDevicePrintingData:data];
                    }
                    else {
                        [[SNBluetooth sharedInstance] writeCharacteristicWithServiceUUID:serviceString
                                                                      characteristicUUID:characteristicsString
                                                                                    data:data];
                    }
                }
                else {
                    NSData *data = [SMCommand formatWithTextType:indexPath.row];
                    if (self.currentPrintType) {
                        [[DeviceDiscoveryCenter sharedManager] controlDevicePrintingData:data];
                    }
                    else {
                        [[SNBluetooth sharedInstance] writeCharacteristicWithServiceUUID:serviceString
                                                                      characteristicUUID:characteristicsString
                                                                                    data:data];
                    }
                }
                NSString *codeType = weakSelf.textCodeArray[selectedIndex];
                weakSelf.codeType = codeType;
                weakSelf.selectedIndex = selectedIndex;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            };
            [codeTypeView show:YES];
        }
        else {
            [SMProgressHUD toastWithText:SMLocalizeString(@"Please connect the printer")];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return 340;
    }
    else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *textLab = [[UILabel alloc]init];
    textLab.frame = CGRectMake(0, 0, tableView.width, 30);
    textLab.textColor = [UIColor lightGrayColor];
    textLab.backgroundColor = tableView.backgroundColor;
    if (section == 0) {
        textLab.text = [NSString stringWithFormat: @"   %@", SMLocalizeString(@"Connected printers")];
    }
    else if (section == 1) {
        textLab.text = [NSString stringWithFormat: @"   %@", SMLocalizeString(@"Encoding format")];
    }
    else {
        textLab.text = [NSString stringWithFormat: @"   %@", SMLocalizeString(@"Print contents")];
    }
    return textLab;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    }
    else {
        return 30;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        UIView *view = [[UIView alloc]init];
        view.frame = CGRectMake(0, 0, tableView.width, 40);
        return view;
    }
    else {
        return [UIView new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 40;
    }
    else {
        return .1f;
    }
}

- (void)addDeviceWithType:(NSInteger)selectIndex {
    __weak typeof(self)weakSelf = self;
    DeviceListViewController *listVc = [[DeviceListViewController alloc]init];
    listVc.printType = selectIndex;
    listVc.connectedStatusBlock = ^(BlueModel * _Nonnull model, PrintConnectType printConnectType) {
        weakSelf.currentModel = model;
        weakSelf.currentPrintType = printConnectType;
        [weakSelf.listTable reloadData];
    };
    [self.navigationController pushViewController:listVc animated:YES];
}



@end
