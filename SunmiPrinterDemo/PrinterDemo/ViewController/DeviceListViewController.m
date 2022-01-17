//
//  DeviceListViewController.m
//  PrinterDemo
//
//  Created by mark on 2020/6/18.
//  Copyright © 2020 mark. All rights reserved.
//

#import "DeviceListViewController.h"
#import "UIView+Frame.h"
#import "SNBluetooth.h"
#import "BlueModel.h"
#import "SMProgressHUD.h"
#import "DeviceDiscoveryCenter.h"

@interface DeviceListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)UIView *headView;
@property(nonatomic, strong)UILabel *searchLab;
@property(nonatomic, strong)UILabel *refreshLab;
@property(nonatomic, strong)UIButton *refreshBTN;
@property(nonatomic, strong)UITableView *listTable;
@property(nonatomic, strong)SNBluetooth *bluetooth;
@property(nonatomic, strong)NSMutableArray <BlueModel *> *dataSource;

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:SMLocalizeString(@"Printer list")];
    self.view.backgroundColor = [UIColor whiteColor];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}
                                               forState:UIControlStateNormal];
    [self.view addSubview:self.headView];
    [self.view addSubview:self.listTable];
    
    [[SNBluetooth sharedInstance] disconnectionDevice];
    
    if (self.printType) {
        [self searchIpDevice];
    }
    else {
        [self searchDevice];
    }
}

- (void)searchIpDevice {
    [SMProgressHUD showWithStatus:SMLocalizeString(@"Searching")];
    __weak typeof(self)weakSelf = self;
    [[DeviceDiscoveryCenter sharedManager] startSearchDeviceWithResultBlock:^(NSArray *deviceModel) {
        [SMProgressHUD hideIndicator];
        [weakSelf.searchLab setText:SMLocalizeString(@"search complete")];
        [weakSelf.refreshLab setHidden:YES];
        [weakSelf.refreshBTN setHidden:NO];
        weakSelf.dataSource = [NSMutableArray arrayWithArray:deviceModel];
        [weakSelf.listTable reloadData];
    }];
}

- (void)searchDevice {
    [SMProgressHUD showWithStatus:SMLocalizeString(@"Searching")];
    __weak typeof(self)weakSelf = self;
    [[SNBluetooth sharedInstance] startScanDevicesWithInterval:5 completeBlock:^(NSArray *devices) {
        [SMProgressHUD hideIndicator];
        NSMutableArray <BlueModel *> *sourceArray = [[NSMutableArray alloc]init];
        for (CBPeripheral *peripheral in devices) {
            BlueModel *model = [[BlueModel alloc]init];
            model.peripheral = peripheral;
            model.uuidString = peripheral.identifier.UUIDString;
            model.deviceName = peripheral.name;
            [sourceArray addObject:model];
        }
        [weakSelf.searchLab setText:SMLocalizeString(@"search complete")];
        [weakSelf.refreshLab setHidden:YES];
        [weakSelf.refreshBTN setHidden:NO];
        NSLog(@"%@", devices);
        weakSelf.dataSource = [NSMutableArray arrayWithArray:sourceArray];
        [weakSelf.listTable reloadData];
    }];
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

- (UIView *)headView {
    if (_headView == nil) {
        _headView = [[UIView alloc]init];
        _headView.frame = CGRectMake(0, kAppNavHeight, self.view.width, 200);
        UIImageView *imgView = [[UIImageView alloc]init];
        imgView.frame = CGRectMake(_headView.width/2 - 40, 30, 80, 80);
        imgView.image = [UIImage imageNamed:@"printer"];
        [_headView addSubview:imgView];
        
        UILabel *searchLab = [[UILabel alloc]init];
        searchLab.text = SMLocalizeString(@"Searching for printers");
        searchLab.frame = CGRectMake(0, imgView.bottom + 10, _headView.width, 20);
        searchLab.textAlignment = NSTextAlignmentCenter;
        searchLab.font = [UIFont fontWithName:Medium_Font size:16];
        searchLab.textColor = [UIColor blackColor];
        [_headView addSubview:searchLab];
        _searchLab = searchLab;
        
        UILabel *refreshLab = [[UILabel alloc]init];
        refreshLab.text = SMLocalizeString(@"The printer found will be displayed below");
        refreshLab.frame = CGRectMake(0, searchLab.bottom + 5, _headView.width, 20);
        refreshLab.textAlignment = NSTextAlignmentCenter;
        refreshLab.font = [UIFont fontWithName:Regular_Font size:14];
        refreshLab.textColor = [UIColor blackColor];
        [_headView addSubview:refreshLab];
        _refreshLab = refreshLab;
        
        
        UIButton *refreshBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        refreshBTN.frame = CGRectMake(_headView.width/2 - 150, refreshLab.y, 300, 40);
        [refreshBTN setTitle:SMLocalizeString(@"Click to search for printers again") forState:UIControlStateNormal];
        [refreshBTN setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [refreshBTN setHidden:YES];
        [refreshBTN addTarget:self action:@selector(tryAgain) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:refreshBTN];
        _refreshBTN = refreshBTN;
    }
    return _headView;
}

- (UITableView *)listTable {
    if (_listTable == nil) {
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, self.headView.bottom, self.view.width, self.view.height - self.headView.bottom) style:UITableViewStyleGrouped];
        _listTable.delegate = self;
        _listTable.dataSource = self;
        _listTable.rowHeight = 60;
        _listTable.backgroundColor = [UIColor whiteColor];
        _listTable.tableFooterView = [UIView new];
        _listTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _listTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _listTable.scrollIndicatorInsets = _listTable.contentInset;
    }
    return _listTable;
}

- (void)tryAgain {
    self.searchLab.text = SMLocalizeString(@"Searching for printers");
    [self.refreshLab setHidden:NO];
    [self.refreshBTN setHidden:YES];
    [self.dataSource removeAllObjects];
    [self.listTable reloadData];
    
    if (self.printType) {
        [self searchIpDevice];
    }
    else {
        [self searchDevice];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
     if (cell == nil) {
         cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
     }
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     
     BlueModel *model = self.dataSource[indexPath.row];
     cell.textLabel.text = model.deviceName.length ? model.deviceName : SMLocalizeString(@"Unknow");
     return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.printType) {
        __weak typeof(self)weakSelf = self;
        BlueModel *model = self.dataSource[indexPath.row];
        [SMProgressHUD showWithStatus:SMLocalizeString(@"Trying to connect")];
        [[DeviceDiscoveryCenter sharedManager] connectSocketWithIP:model.deviceIP completeBlock:^(NSError *err) {
            [SMProgressHUD hideIndicator];
            if (err.code == 401) {
                [weakSelf.listTable reloadData];
                if (weakSelf.connectedStatusBlock) {
                    weakSelf.connectedStatusBlock(model, weakSelf.printType);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            else {
                [SMProgressHUD toastWithText:SMLocalizeString(@"connection failed")];
            }
        }];
    }
    else {
        __weak typeof(self)weakSelf = self;
        BlueModel *model = self.dataSource[indexPath.row];
        [SMProgressHUD showWithStatus:SMLocalizeString(@"Trying to connect")];
        [[SNBluetooth sharedInstance] connectionWithDeviceUUID:model.uuidString timeOut:10 completeBlock:^(CBPeripheral *device, NSError *err) {
            NSLog(@"%@",  device);
            [SMProgressHUD hideIndicator];
            if (device.state == CBPeripheralStateConnected) {
                [weakSelf.listTable reloadData];
                if (weakSelf.connectedStatusBlock) {
                    weakSelf.connectedStatusBlock(model, weakSelf.printType);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            else {
                [SMProgressHUD toastWithText:SMLocalizeString(@"connection failed")];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *textLab = [[UILabel alloc]init];
    textLab.frame = CGRectMake(0, 0, tableView.width, 40);
    textLab.backgroundColor = COLOR_F5;
    textLab.textAlignment = NSTextAlignmentLeft;
    textLab.font = [UIFont fontWithName:Regular_Font size:14];
    textLab.text = [NSString stringWithFormat:@"   %@", SMLocalizeString(@"Please select a printer to connect to")];
    return textLab;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}


@end
