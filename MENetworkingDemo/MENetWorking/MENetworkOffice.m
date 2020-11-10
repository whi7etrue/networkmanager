//
//  MENetworkOffice.m
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MENetworkOffice.h"
#import "MENetworkServer.h"
#import <AFNetworking/AFNetworking.h>
#import "MJExtension.h"
#import "NSURLRequest+MENetworking.h"
#import "MEBaseAPIManager.h"

@interface MENetworkOffice ()

@property (nonatomic ,copy) NSDictionary *APIConfigsDict;

@property (nonatomic ,strong) AFHTTPRequestSerializer *unicodeRequest;

@property (nonatomic ,strong) AFJSONRequestSerializer *jsonRequest;

@property (nonatomic ,strong) NSMutableArray *networkResumeRetryRequests;

@end


@implementation MENetworkOffice

+(instancetype)shareOffice{
    
    static MENetworkOffice *shareServe = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareServe = [[MENetworkOffice alloc] init];
        
        shareServe.networkServe = [[MENetworkServer alloc] init];
        
        shareServe.networkResumeRetryRequests = [NSMutableArray array];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [shareServe networkMonit];
        
        [shareServe APIConfigsDict];
        
    });
    return shareServe;
}

-(void)setRoleType:(MENetworkRoleType)roleType{
    
    _roleType = roleType;
    
#ifdef DEBUG
    
    self.host = [self getLocalHost];
    
#else
    
    [self getLocalHost];
    
    if (roleType == MENetworkRoleType_student) {
        
        self.host = @"https://mmears.com";
    }else{
        
        self.host = @"https://t.uw.mmears.com";
    }
    
#endif
}

-(NSString *)getLocalHost{
    
    NSString *apiPath = [[NSBundle mainBundle] pathForResource:@"MEHostConfig" ofType:@"plist"];
    
    NSDictionary *temp = [NSDictionary dictionaryWithContentsOfFile:apiPath];
    
    self.versionTest = temp[@"versionTest"];
    
    return temp[@"host"];
}

-(void)networkMonit{
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
            
            for (MEBaseAPIManager *tempManger in self.networkResumeRetryRequests) {
                
                tempManger.errorType = MEBaseAPIManagerErrorTypeNetWorkResume;
                [tempManger.delegate managerCallAPIDidFailed:tempManger];
                
                [tempManger loadData];
            }
            
            [self.networkResumeRetryRequests removeAllObjects];
        }
        
    }];
}

- (void)networkResumeRetryRequestsAddRequest:(MEBaseAPIManager *)manager{
    
    if (![self.networkResumeRetryRequests containsObject:manager]) {
        
        [self.networkResumeRetryRequests addObject:manager];
    }
}

- (void)networkResumeRetryRequestsRemoveRequest:(MEBaseAPIManager *)manager{
    
    if ([self.networkResumeRetryRequests containsObject:manager]) {
        
        [self.networkResumeRetryRequests removeObject:manager];
    }
}

- (NSArray *)errorStringArr{
    
    if (!_errorStringArr) {
        
        if([MENetworkOffice shareOffice].roleType == MENetworkRoleType_student){
            
            _errorStringArr = @[DefaulErrorString,loadingErrorString,NoContentErrorString,ParamsErrorString,TimeoutErrorString,NoNetWorkErrorString,loadingErrorString];
        }else{
            
            _errorStringArr = @[DefaulErrorStringT,loadingErrorStringT,NoContentErrorStringT,ParamsErrorStringT,TimeoutErrorStringT,NoNetWorkErrorStringT,loadingErrorStringT];
        }
    }
    
    return _errorStringArr;
    
}

- (NSCache *)responseCache{
    
    if (_responseCache == nil) {
        
        _responseCache = [[NSCache alloc] init];
    }
    return _responseCache;
}

- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}


#pragma mark 获得request的过程抽取 将业务逻辑分离
-(NSMutableURLRequest *)MEParamsToRequestWithPath:(NSString *)path pramas:(NSDictionary *)params paramsType:(MENetworkParamsType)paramsType requestType:(MERequestType)requestType config:(MERequestConfig *)config{

    AFHTTPRequestSerializer *requestSerial;
    
    if (paramsType == MENetworkParamsType_unicode) {
        
        requestSerial = self.unicodeRequest;
    }else{
        
        requestSerial = self.jsonRequest;
    }
    
    requestSerial.timeoutInterval = config.apiNetworkingTimeoutSeconds;
    
    NSString *method;
    
    switch (requestType) {
        case MERequestType_GET:{
            
            method = @"GET";
        }
            break;
            
        case MERequestType_Post:{
            
            method = @"POST";
        }
            break;
            
        case MERequestType_Put:{
            
            method = @"PUT";
        }
            break;
            
        default:
            break;
    }
    
    NSString *totalPath;
    
    if (![path hasPrefix:@"http://"]&&![path hasPrefix:@"https://"]) {
        
        totalPath = [NSString stringWithFormat:@"%@%@",[MENetworkOffice shareOffice].host,path];
    }else{
        
        if ([path hasPrefix:@"https://itunes.apple.com"]) {
            
            AFHTTPRequestSerializer *specialRequestSerial;
            
            if (paramsType == MENetworkParamsType_unicode) {
                
                specialRequestSerial = [AFHTTPRequestSerializer serializer];
            }else{
                
                specialRequestSerial = [AFJSONRequestSerializer serializer];
            }
            
            NSError *specialSerializationError = nil;
            
            NSMutableURLRequest *request = [specialRequestSerial requestWithMethod:method URLString:[[NSURL URLWithString:path relativeToURL:nil] absoluteString] parameters:params error:&specialSerializationError];
            
//            request.requestParams = params.copy;
            
            return request;
        }
        
        totalPath = path;
    }
    
    [requestSerial setValue:self.host forHTTPHeaderField:@"Referer"];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [self.extraParmas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        [tempDict setObject:obj forKey:key];
    }];
    
//    NSLog(@"request: %@--params: %@",requestSerial.HTTPRequestHeaders,tempDict);
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerial requestWithMethod:method URLString:[[NSURL URLWithString:totalPath relativeToURL:nil] absoluteString] parameters:tempDict error:&serializationError];
    
    request.requestParams = tempDict.copy;
    
    return request;
}

#pragma mark ---根据枚举值获取请求接口
+ (MERequestConfig *)fetchConfigWitMethodNameType:(MERequestMethodNameType)nameType{
    
    NSString *key = [self getMethodNameWithType:nameType];
    NSDictionary *configDict = [MENetworkOffice shareOffice].APIConfigsDict[key];
    
    MERequestConfig *config = [MERequestConfig mj_objectWithKeyValues:configDict];
    
    //如果没有设置 shouldCache shouldAutoTry 默认值为NO  networkResumeShouldAutoTry 默认值为YES
    if (configDict[@"shouldCache"] == nil) {
        
        config.shouldCache = NO;
    }
    
    if (configDict[@"shouldAutoTry"] == nil) {
        
        config.shouldAutoTry = NO;
    }
    
    if (configDict[@"networkResumeShouldAutoTry"] == nil){
        
        config.networkResumeShouldAutoTry = NO;
    }
    
    config.request_methodName = key;
    
    return config;
}

+ (NSString *)getMethodNameWithType:(MERequestMethodNameType)type{
    
    switch (type) {
        case MERequestMethodNameType_courseDownLoadInfo:{
            
//            return @"/yosemite/courseware/student_download";
            return @"/mservice/courseware-service/resource/download";

        }
            break;
        case MERequestMethodNameType_checkCourseInfo:{
            
//            return @"/yosemite/classroom/info";
            return @"/mservice/courseware-service/classroom/info";

        }
            break;
        case MERequestMethodNameType_getHelpDataInfo:{
            
            return @"/yosemite/issue/list";
        }
            break;
        case MERequestMethodNameType_getClassroomToken:{
            
            return @"/client/classroom/token";
        }
            break;
        case MERequestMethodNameType_getClassroomState:{
            
            return @"/client/classroom/status";
        }
            break;
        case MERequestMethodNameType_appAPIHostSettingURL:{
            
            return @"/yosemite/hosts";
        }
            break;
            
        case MERequestMethodNameType_newVersionInfoURL:{
            
            return @"/yosemite/file/latest_version";
        }
            break;
            
        case MERequestMethodNameType_loginURL:{
            
            return @"/id/login/pwd";
        }
            break;
        case MERequestMethodNameType_registerURL:{
            
            return @"/id/register/phone";
        }
            break;
        case MERequestMethodNameType_resetPwdURL:{
            
            return @"/id/resetpwd";
        }
            break;
        case MERequestMethodNameType_phoneCheckURL:{
            
            return @"/id/phone/check";
        }
            break;
        case MERequestMethodNameType_registerCodeURL:{
            
            return @"/id/register/code";
        }
            break;
        case MERequestMethodNameType_resetpwdCodeURL:{
            
            return @"/id/resetpwd/code";
        }
            break;
        case MERequestMethodNameType_studentnfoURL:{
            
            return @"/yosemite/student_info";
        }
            break;
        case MERequestMethodNameType_previewsInfoURL:{
            
            return @"/previews/v1/info";
        }
            break;
        case MERequestMethodNameType_previewsScoreSubmitURL:{
            
            return @"/previews/v1/score/submit";
        }
            break;
        case MERequestMethodNameType_studentEvaluationURL:{
            
            return @"/yosemite/student/evaluation";
        }
            break;
        case MERequestMethodNameType_createOrderURL:{
            
            return @"/pay/api/create_order_client";
        }
            break;
        case MERequestMethodNameType_payInfoURL:{
            
            return @"/pay/api/pay_info_client";
        }
            break;
        case MERequestMethodNameType_successPaidURL:{
            
            return @"/pay/api/client_success_paid";
        }
            break;
        case MERequestMethodNameType_aboutClassURL:{
            
            return @"/api/course/booking";
        }
            break;
        case MERequestMethodNameType_postAboutClassURL:{
            
            return @"/api/course/book";
        }
            break;
        case MERequestMethodNameType_checkDeviceURL:{
            
            return @"/yosemite/facility/add";
        }
            break;
        case MERequestMethodNameType_latestVersionURL:{
            
            return @"/yosemite/file/latest_version";
        }
            break;
        case MERequestMethodNameType_checkAppStoreVersionURL:{
            
            return @"/itunes.apple.com/lookup";
        }
            break;
        case MERequestMethodNameType_checkTokenURL:{
            
            return @"/id/login/check";
        }
            break;
        case MERequestMethodNameType_courseConfigURL:{
            
            return @"/api/course/server/config";
        }
            break;
        case MERequestMethodNameType_courseListURL:{
            
            return @"/api/course/info/list";
        }
            break;
        case MERequestMethodNameType_getSettingGateURL:{
            
            return @"/yosemite/triggers";
        }
            break;
        case MERequestMethodNameType_editInfoUrl:{
            
            return @"/yosemite/student_info/update";
        }
            break;
        case MERequestMethodNameType_getOnceTokenUrl:{
            
            return @"/mservice/token-generator";
        }
            break;
        case MERequestMethodNameType_addEventTrackingUrl:{
            
            return @"/shence/addEvent";
        }
            break;
        case MERequestMethodNameType_logoutUrl:{
            
            return @"/id/logout";
        }
            break;
        case MERequestMethodNameType_padSetting: {
            return @"/yosemite/pad/setting";
        }
            break;
            
        case MERequestMethodNameType_teacherInfoURL: {
            return @"/api/teacher/teacher_info";
        }
            break;
        default:
            break;
    }
    
    return nil;
}

-(NSDictionary *)APIConfigsDict{
    
    if (_APIConfigsDict == nil) {

       NSString *apiPath = [[NSBundle mainBundle] pathForResource:@"MENetworkOffice" ofType:@"plist"];
        
        _APIConfigsDict = [NSDictionary dictionaryWithContentsOfFile:apiPath];
    }
    return _APIConfigsDict;
}

//request_ParamsType 0 unicode 1 jason
//request_Type 0 get 1 post
-(NSDictionary *)creatAPIConfigsDict{
    
    return @{@"/yosemite/file/latest_version":@{
                     @"request_ParamsType":@(0),
                     @"request_Type":@(0),
                     @"shouldCache":@(YES),
                     @"cacheOutdateTimeSeconds":@(300),
                     @"apiNetworkingTimeoutSeconds":@(10),
                     @"shouldAutoTry":@(YES),
                     @"tryTimeouts":@[@(5),@(6),@(7),@(8)]
                     }
             
             };
}

-(void)setHttpHeaderCookie:(NSString *)cookie{
    
    [self.unicodeRequest setValue:cookie forHTTPHeaderField:@"Cookie"];
    [self.jsonRequest setValue:cookie forHTTPHeaderField:@"Cookie"];
}

-(AFHTTPRequestSerializer *)unicodeRequest{
    
    if (_unicodeRequest == nil) {
        
        _unicodeRequest = [AFHTTPRequestSerializer serializer];
        
        [self.extraHttpHeaderParmas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if ([key isEqualToString:@"User-Agent"]) {
                
                NSString *str = [NSString stringWithFormat:@"%@;deviceId=%@",_unicodeRequest.HTTPRequestHeaders[@"User-Agent"],obj];
                
                [_unicodeRequest setValue:str forHTTPHeaderField:key];

            }else{
                
                [_unicodeRequest setValue:obj forHTTPHeaderField:key];
            }
        }];
    }
    return _unicodeRequest;
}

-(AFJSONRequestSerializer *)jsonRequest{
    
    if (_jsonRequest == nil) {
        
        _jsonRequest = [AFJSONRequestSerializer serializer];
        
        [self.extraHttpHeaderParmas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if ([key isEqualToString:@"User-Agent"]) {
                
                NSString *str = [NSString stringWithFormat:@"%@;deviceId=%@",_jsonRequest.HTTPRequestHeaders[@"User-Agent"],obj];
                
                [_jsonRequest setValue:str forHTTPHeaderField:key];
            }else{
                
                [_jsonRequest setValue:obj forHTTPHeaderField:key];
            }
            
        }];
    }
    return _jsonRequest;
}

@end
