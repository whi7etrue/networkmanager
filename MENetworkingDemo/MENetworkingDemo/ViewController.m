//
//  ViewController.m
//  MENetworkingDemo
//
//  Created by 陈建才 on 2018/5/23.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "ViewController.h"
#import "MENormalAPIManger.h"

@interface ViewController ()<MEBaseAPIManagerCallBackDelegate,MEBaseAPIManagerInterceptor>

@property (nonatomic ,strong) MENormalAPIManger *testConfigManager;

@property (nonatomic ,strong) MENormalAPIManger *ceshiConfigManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self testConfigManager];
    [self ceshiConfigManager];
}

-(MENormalAPIManger *)testConfigManager{
    
    if (_testConfigManager == nil) {
        
        _testConfigManager = [[MENormalAPIManger alloc] initWithAPIType:MERequestMethodNameType_newVersionInfoURL];
        _testConfigManager.delegate = self;
//        _testConfigManager.paramSource = self;
        _testConfigManager.interceptor = self;
    }
    return _testConfigManager;
}

-(MENormalAPIManger *)ceshiConfigManager{
    
    if (_ceshiConfigManager == nil) {
        
        _ceshiConfigManager = [[MENormalAPIManger alloc] initWithAPIType:MERequestMethodNameType_loginURL];
        _ceshiConfigManager.delegate = self;
        _ceshiConfigManager.interceptor = self;
    }
    return _ceshiConfigManager;
}

-(BOOL)manager:(MEBaseAPIManager *)manager shouldCallAPIWithParams:(NSDictionary *)params{
    
    if (manager == self.testConfigManager) {
        
        [manager setRequestConfigRequestType:MERequestType_GET];
        
        [manager setRequestConfigMethodName:@"https://itunes.apple.com/lookup?id=1335465718"];
    }else{
        
        [manager setRequestConfigRequestType:MERequestType_Post];
        
        [manager setRequestConfigMethodName:@"/id/login/pwd"];
    }
    
    return YES;
}

-(void)managerCallAPIDidSuccess:(MEBaseAPIManager *)manager{
    
    MEURLResponse *res = manager.urlResponse;
    
    NSLog(@"MEBaseAPIManager-------%@",manager);
}

-(void)managerCallAPIDidFailed:(MEBaseAPIManager *)manager{
    
    NSLog(@"MEBaseAPIManager------- fail %@",manager.errorMessage);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"network =====%tu",[MENetworkOffice shareOffice].isReachable);
    
//    self.testConfigManager.params = @{@"externalId":@"18600315049", @"password":@"12345678",@"sid":@"passport",@"keepLogin":@"true",@"device":@"ipad"};
    self.testConfigManager.params = nil;
    [self.testConfigManager loadData];
    
    self.ceshiConfigManager.params = @{@"externalId":@"18600315048", @"password":@"12345678",@"sid":@"passport",@"keepLogin":@"true",@"device":@"ipad"};
    [self.ceshiConfigManager loadData];
}

-(NSDictionary *)paramsForApi:(MEBaseAPIManager *)manager{
    
    return @{@"externalId":@"13460259617", @"password":@"12345678",@"sid":@"passport",@"keepLogin":@"true",@"device":@"ipad"};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
