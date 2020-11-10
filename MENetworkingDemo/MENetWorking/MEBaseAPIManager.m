//
//  MEBaseAPIManager.m
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MEBaseAPIManager.h"
#import "MENetworkServer.h"
#import "MERequestConfig.h"
#import "MEURLResponse.h"
#import "MENetworkOffice.h"
#import "MEDataCacheObject.h"
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, MEBaseAPIManagerType) {
    MEBaseAPIManagerType_config,
    MEBaseAPIManagerType_protocol,
    MEBaseAPIManagerType_DownAndUpload
};

@interface MEBaseAPIManager ()

@property (nonatomic, strong, readwrite) id fetchedRawData;
@property (nonatomic, assign, readwrite) BOOL isLoading;

@property (nonatomic ,assign) MEBaseAPIManagerType managerType;

@property (nonatomic, strong) MERequestConfig *config;

@property (nonatomic, assign) NSInteger requestId;

@property (nonatomic ,copy) NSArray *tryItems;

@property (nonatomic ,assign) NSInteger tryCount;

@end

@implementation MEBaseAPIManager

-(instancetype)initWithAPIType:(MERequestMethodNameType)methodNameType{
    
    if ([self isMemberOfClass:[MEBaseAPIManager class]]) {
        
        NSException *exception = [[NSException alloc] initWithName:@"错误提示" reason:[NSString stringWithFormat:@"%@是抽象类，不能直接使用",self] userInfo:nil];
        @throw exception;
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        [self setUpBaseConfig];
        
        self.managerType = MEBaseAPIManagerType_config;
        _config = [MENetworkOffice fetchConfigWitMethodNameType:methodNameType];
    }
    return self;
}

- (instancetype)init
{
    
    if ([self isMemberOfClass:[MEBaseAPIManager class]]) {
        
        NSException *exception = [[NSException alloc] initWithName:@"错误提示" reason:[NSString stringWithFormat:@"%@是抽象类，不能直接使用",self] userInfo:nil];
        @throw exception;
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        [self setUpBaseConfig];
        
        //自定义协议的配置
        _config = [[MERequestConfig alloc] init];
        _config.apiNetworkingTimeoutSeconds = 20.f;
        
        self.managerType = MEBaseAPIManagerType_protocol;
        
        if ([self conformsToProtocol:@protocol(MEBaseAPIManager)]) {
            self.child = (id <MEBaseAPIManager>)self;
        } else {
            self.child = (id <MEBaseAPIManager>)self;
            NSException *exception = [[NSException alloc] initWithName:@"错误提示" reason:[NSString stringWithFormat:@"%@没有遵循MEBaseAPIManager协议",self.child] userInfo:nil];
            @throw exception;
        }
    }
    return self;
}

-(void)setUpBaseConfig{
    
    _delegate = nil;
    _validator = nil;
//    _paramSource = nil;
    
    _fetchedRawData = nil;
    
    _errorMessage = nil;
    _errorType = 0;
    _requestId = 0;
    _tryCount = 0;
}

- (void)dealloc
{
    
    [[MENetworkOffice shareOffice] networkResumeRetryRequestsRemoveRequest:self];
    
    [self cancelRequest];
}

- (void)setRequestConfigRequestType:(MERequestType)type{
    
    self.config.request_Type = type;
}

- (void)setRequestConfigRequestParamsType:(MENetworkParamsType)type{
    
    self.config.request_ParamsType = type;
}

- (void)setRequestConfigMethodName:(NSString *)newMethodName{
    
    self.config.request_methodName = newMethodName;
}

- (void)setRequestConfigTimeouts:(NSDictionary *)timeoutConfig{
    
    if (timeoutConfig) {
        
        NSNumber *timeoutNum = timeoutConfig[@"setting"];
        NSNumber *retryNum = timeoutConfig[@"retry"];
        NSInteger timeout = timeoutNum.integerValue;
        NSInteger retry = retryNum.integerValue;
        
        if (timeout > 0) {
            
            self.config.apiNetworkingTimeoutSeconds = timeout;
            
            if (retry > 0) {
                
                self.config.shouldAutoTry = YES;
                
                NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:retry];
                for (int i=0; i<retry; i++) {
                    
                    [tempArr addObject:timeoutNum];
                }
                
                self.config.tryTimeouts = tempArr.copy;
            }
        }
    }
    
//    NSLog(@"setRequestConfigTimeouts :%@ ,autotry: %tu",self.config.tryTimeouts,self.config.shouldAutoTry);
}

- (NSInteger)loadData
{
    NSDictionary *params = self.params;
    self.requestId = [self loadDataWithParams:params];
    return self.requestId;
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params
{

    NSDictionary *apiParams = [self reformParams:params];
    if ([self shouldCallAPIWithParams:apiParams]) {
        if ([self isCorrectWithParamsData:apiParams]) {
        
            // 先检查一下是否有缓存
            if ([self shouldCache] && [self hasCacheWithParams:apiParams]) {
                
                NSLog(@"has cache dont need request");
                
                return 0;
            }
            
            // 实际的网络请求
            if ([self isReachable]) {
                self.isLoading = YES;
                
                switch (self.managerType) {
                    case MEBaseAPIManagerType_protocol://基于协议自定义请求
                    {
                        
                       self.requestId = [self useNetworkServerRequestWithType:self.child.requestType];
                        
                    }
                        break;
                    case MEBaseAPIManagerType_config://基于配置定义请求
                    {
                        self.requestId = [self useNetworkServerRequestWithConfig];
                        
                    }
                        break;
                        
                    default:
                        break;
                }
                
                
                NSMutableDictionary *params = [apiParams mutableCopy];
                params[kMEBaseAPIManagerRequestID] = @(self.requestId);
                [self afterCallingAPIWithParams:params];
                return self.requestId;
                
            } else {
                
                if ([self networkResumeFailRequestshouldAutoTry]){
                    
                    [[MENetworkOffice shareOffice] networkResumeRetryRequestsAddRequest:self];
                }
                
                [self failedOnCallingAPI:nil withErrorType:MEBaseAPIManagerErrorTypeNoNetWork];
                return self.requestId;
            }
        } else {
            [self failedOnCallingAPI:nil withErrorType:MEBaseAPIManagerErrorTypeParamsError];
            return self.requestId;
        }
    }
    return self.requestId;
}

#pragma mark - 根据配置请求的实现

-(NSInteger)useNetworkServerRequestWithConfig{
    
    __weak typeof(self) weakSelf = self;
    
//    NSString *path = [NSString stringWithFormat:@"%@%@",[MENetworkOffice shareOffice].host,self.config.request_methodName];
    
    NSInteger requestId = [[MENetworkOffice shareOffice].networkServe MECallServeWithConfig:self.config Params:self.params path:self.config.request_methodName success:^(MEURLResponse *response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        self.tryCount = 0;
        [strongSelf successedOnCallingAPI:response];
        
    } fail:^(MEURLResponse *response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([self shouldAutoTryWithTimeouts]) {
            
//            NSLog(@"apimanager auto try-------%tu--%f",self.tryCount,self.config.apiNetworkingTimeoutSeconds);
            
            [self loadData];
            
        }else{
            
            self.tryCount = 0;
            MEURLResponse *urlResponse = response;
            
            [strongSelf failedOnCallingAPI:response withErrorType:urlResponse.error.code == NSURLErrorTimedOut ? MEBaseAPIManagerErrorTypeTimeout : MEBaseAPIManagerErrorTypeDefault];
        }
        
    }];
    
    return requestId;
}

#pragma mark - 自定义协议请求的实现

-(NSInteger)useNetworkServerRequestWithType:(MERequestType)type{
    
    if (self.child.requestType == MERequestType_Download) {
        //下载任务的实现
        return [self startDownloadNetworkRequest];
        
    }else if (self.child.requestType == MERequestType_Upload){
        //上传任务的实现
        
        return [self startUploadNetWorkRequest];
    }else{
        
        //GETorPOST请求的实现
        
        return [self startGETorPOSTNetworkRequest];
        
    }
    
}

#pragma mark - 自定义协议中GET和POST请求的实现

- (NSInteger)startGETorPOSTNetworkRequest{
    
    __weak typeof(self) weakSelf = self;
    
//    NSString *path = [NSString stringWithFormat:@"%@%@",[MENetworkOffice shareOffice].host,[self.child methodName]];
    
    NSInteger requestId = [[MENetworkOffice shareOffice].networkServe MECallServeWithRequestType:self.child.requestType Params:self.params paramsType:[self.child paramsType] path:[self.child methodName] config:self.config success:^(id response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.tryCount = 0;
        [strongSelf successedOnCallingAPI:response];
        
    } fail:^(id response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([strongSelf shouldAutoTryWithTimeouts]) {
            
//            NSLog(@"apimanager auto try-------%tu--%f",strongSelf.tryCount,strongSelf.config.apiNetworkingTimeoutSeconds);
            
            [strongSelf loadData];
            
        }else{
            
            strongSelf.tryCount = 0;
            
            MEURLResponse *urlResponse = response;
            
            [strongSelf failedOnCallingAPI:response withErrorType:urlResponse.error.code == NSURLErrorTimedOut ? MEBaseAPIManagerErrorTypeTimeout : MEBaseAPIManagerErrorTypeDefault];
        }
        
    }];
    
    return requestId;
    
    
}

#pragma mark - 自定义协议中下载请求实现

- (NSInteger)startDownloadNetworkRequest{
    
    __weak typeof(self) weakSelf = self;
    
    NSInteger requestId = [[MENetworkOffice shareOffice].networkServe MEcallDOWNLOADRequestWithDownloadParams:self.params requestPath:[self.child methodName] paramsType:[self.child paramsType] config:self.config progress:^(NSProgress *progress) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        
        if ([strongSelf.delegate respondsToSelector:@selector(managerCallAPIWithManger:netWorkProgress:)]) {
            
            [strongSelf.delegate managerCallAPIWithManger:strongSelf netWorkProgress:progress];
        }
        
    } success:^(MEURLResponse *response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf successedOnCallingAPI:response];
        
    } fail:^(MEURLResponse *response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf failedOnCallingAPI:response withErrorType:response.error.code == NSURLErrorTimedOut ? MEBaseAPIManagerErrorTypeTimeout : MEBaseAPIManagerErrorTypeDefault];
        
    }];
    
    return requestId;
    
}

#pragma mark - 自定义协议上传接口的实现

- (NSInteger)startUploadNetWorkRequest{
    
    __weak typeof(self) weakSelf = self;
    
//    NSString *path = [NSString stringWithFormat:@"%@%@",[MENetworkOffice shareOffice].host,[self.child methodName]];
    
    NSInteger requestId = [[MENetworkOffice shareOffice].networkServe MEcallUPLOADRequestWithUploadParams:self.params requestPath:[self.child methodName] paramsType:[self.child paramsType] config:self.config progress:^(NSProgress *progress) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([strongSelf.delegate respondsToSelector:@selector(managerCallAPIWithManger:netWorkProgress:)]) {
            
            [strongSelf.delegate managerCallAPIWithManger:strongSelf netWorkProgress:progress];
        }
        
    } success:^(MEURLResponse *response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf successedOnCallingAPI:response];
        
    } fail:^(MEURLResponse *response) {
       
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf failedOnCallingAPI:response withErrorType:response.error.code == NSURLErrorTimedOut ? MEBaseAPIManagerErrorTypeTimeout : MEBaseAPIManagerErrorTypeDefault];
        
    }];
    
    return requestId;
    
}

#pragma mark - api callbacks
- (void)successedOnCallingAPI:(MEURLResponse *)response
{
    self.isLoading = NO;
    self.urlResponse = response;
    
    if ([self isCorrectWithCallBackData:response.content]) {

        if ([self shouldCache] && !response.isCache) {
            
            MEDataCacheObject *cache = [[MEDataCacheObject alloc] initWithContent:response.content];
            
            if (self.managerType == MEBaseAPIManagerType_config) {
                
                cache.effectiveDuration = self.config.cacheOutdateTimeSeconds;
            }
            
            NSString *key = [MEDataCacheObject keyWithMethodName:[self getRequestMethod] andParams:self.params];
            
            [[MENetworkOffice shareOffice].responseCache setObject:cache forKey:key];
        }

        if ([self beforePerformSuccessWithResponse:response]) {

            [self.delegate managerCallAPIDidSuccess:self];
        }
        [self afterPerformSuccessWithResponse:response];
    } else {
        [self failedOnCallingAPI:response withErrorType:MEBaseAPIManagerErrorTypeNoContent];
    }
}

- (void)failedOnCallingAPI:(MEURLResponse *)response withErrorType:(MEBaseAPIManagerErrorType)errorType
{
    self.isLoading = NO;
    self.urlResponse = response;
    
    //继续错误的处理
    self.errorType = errorType;
    
    if (errorType == MEBaseAPIManagerErrorTypeNoNetWork) {
        
        NSError *error = [NSError errorWithDomain:@"no net work" code:-1009 userInfo:nil];
        
        MEURLResponse *ruturnRes = [[MEURLResponse alloc] initWithResponseString:nil requestId:0 request:nil error:error];
        
        self.urlResponse = ruturnRes;
    }
    
    self.errorMessage = [MENetworkOffice shareOffice].errorStringArr[errorType];
    
    if ([self beforePerformFailWithResponse:response]) {
        [self.delegate managerCallAPIDidFailed:self];
    }
    [self afterPerformFailWithResponse:response];
}

-(NSString *)getRequestMethod{
    
    NSString *methodName;
    
    if (self.managerType == MEBaseAPIManagerType_protocol) {
        
        methodName = [self.child methodName];
    }else{
        
        methodName = self.config.request_methodName;
    }
    
    return methodName;
}

#pragma mark - method for interceptor
- (BOOL)beforePerformSuccessWithResponse:(MEURLResponse *)response
{
    BOOL result = YES;
    
    self.errorType = MEBaseAPIManagerErrorTypeSuccess;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager: beforePerformSuccessWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    return result;
}

- (void)afterPerformSuccessWithResponse:(MEURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponse:(MEURLResponse *)response
{
    BOOL result = YES;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
    return result;
}

- (void)afterPerformFailWithResponse:(MEURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

//只有返回YES才会继续调用API
- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    } else {
        return YES;
    }
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

#pragma mark - method for Validator
- (BOOL)isCorrectWithParamsData:(NSDictionary *)params{
    
    if (self != self.validator && [self.validator respondsToSelector:@selector(isCorrectWithParamsData:)]) {
        
        return [self.validator manager:self isCorrectWithParamsData:params];
    }else{
        
        return YES;
    }
}

- (BOOL)isCorrectWithCallBackData:(NSDictionary *)params{
    
    if (self != self.validator && [self.validator respondsToSelector:@selector(isCorrectWithParamsData:)]) {
        
        return [self.validator manager:self isCorrectWithCallBackData:params];
        
    }else{
        
        return YES;
    }
}

#pragma mark autoTry
- (BOOL)shouldAutoTryWithTimeouts{
    
    if (self.managerType == MEBaseAPIManagerType_protocol) {
        
        return [self shouldAutoTryWithTimeoutsProtocol];
    }else if(self.managerType == MEBaseAPIManagerType_config){
        
        return [self shouldAutoTryWithTimeoutsConfig];
    }
    
    return NO;
}

-(BOOL)shouldAutoTryWithTimeoutsProtocol{
    
    if ([self.autoTry respondsToSelector:@selector(shouldAutoTry)]&&[self.autoTry respondsToSelector:@selector(tryWithTimeouts)]) {
        
        self.tryItems = [self.autoTry tryWithTimeouts];
        
        if (self.tryItems.count>0) {
            
            if (self.tryCount >= self.tryItems.count) {
                
                return NO;
            }
            
            NSNumber *timeoutNum = self.tryItems[self.tryCount];
            self.config.apiNetworkingTimeoutSeconds = timeoutNum.floatValue;
            self.tryCount++;
            
            return [self.autoTry shouldAutoTry];
        }
        
        return NO;
        
    }else{
        
        return NO;
    }
}

-(BOOL)shouldAutoTryWithTimeoutsConfig{
    
    if (self.config.shouldAutoTry) {
        
        if (self.config.tryTimeouts.count>0) {
            
            if (self.tryCount >= self.config.tryTimeouts.count) {
                
                return NO;
            }
            
            NSNumber *timeoutNum = self.config.tryTimeouts[self.tryCount];
            self.config.apiNetworkingTimeoutSeconds = timeoutNum.floatValue;
            self.tryCount++;
            
            return YES;
        }
        
        return NO;
    }
    
    return NO;
}

#pragma mark -method for networkResumeFailRequestshouldAutoTry
-(BOOL)networkResumeFailRequestshouldAutoTry{
    
    if (self.managerType == MEBaseAPIManagerType_protocol) {
        
        return [self networkResumeFailRequestshouldAutoTryProtocol];
    }else if(self.managerType == MEBaseAPIManagerType_config){
        
        return [self networkResumeFailRequestshouldAutoTryConfig];
    }
    
    return NO;
}

-(BOOL)networkResumeFailRequestshouldAutoTryProtocol{
    
    if (self.networkAutoTry &&[self.networkAutoTry respondsToSelector:@selector(netWorkResumeShouldAutoTry)]) {
        
        return [self.networkAutoTry netWorkResumeShouldAutoTry];
    }
    
    return YES;
}

-(BOOL)networkResumeFailRequestshouldAutoTryConfig{
    
    return self.config.networkResumeShouldAutoTry;
}

#pragma mark - method for child
- (void)cleanData
{
    if (self.child.methodName) {
        
        [[MENetworkOffice shareOffice].responseCache removeObjectForKey:[self.child methodName]];
    }
    
    self.fetchedRawData = nil;
    self.errorMessage = nil;
    self.errorType = MEBaseAPIManagerErrorTypeDefault;
}

//如果需要在调用API之前额外添加一些参数，比如pageNumber和pageSize之类的就在这里添加
//子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
- (NSDictionary *)reformParams:(NSDictionary *)params
{
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        // 如果child是继承得来的，那么这里就不会跑到，会直接跑子类中的IMP。
        // 如果child是另一个对象，就会跑到这里
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
}

- (BOOL)shouldCache{

    if (self.managerType == MEBaseAPIManagerType_protocol) {
        
        if (self.child && [self.child respondsToSelector:@selector(shouldCache)]) {
            
            return [self.child shouldCache];
        }
        
        return NO;
    }else if (self.managerType == MEBaseAPIManagerType_config){
        
        return self.config.shouldCache;
    }
    
    return NO;
}

- (BOOL)hasCacheWithParams:(NSDictionary *)params
{
//    NSString *methodName = self.child.methodName;
    id result = [MEDataCacheObject fetchCachedDataWithMethodName:[self getRequestMethod] andParams:self.params];
    
    if (result == nil) {
        return NO;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        MEURLResponse *response = [[MEURLResponse alloc] initWithContent:result];
    
        [strongSelf successedOnCallingAPI:response];
    });
    return YES;
}

- (void)cancelRequest
{

    [[MENetworkOffice shareOffice].networkServe cancelRequestWithRequestID:@(self.requestId)];
}

#pragma mark - getters and setters

- (BOOL)isReachable
{
    BOOL isReachability = [MENetworkOffice shareOffice].isReachable;
    if (!isReachability) {
        self.errorType = MEBaseAPIManagerErrorTypeNoNetWork;
    }
    return isReachability;
}


@end
