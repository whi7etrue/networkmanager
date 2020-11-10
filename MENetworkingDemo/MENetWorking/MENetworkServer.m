//
//  MENetworkServe.m
//  METestAPIManager
//
//  Created by 陈建才 on 2018/5/17.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MENetworkServer.h"
#import <AFNetworking/AFNetworking.h>
#import "MEURLResponse.h"
#import "MENetworkOffice.h"
#import "MERequestAPIConfig.h"
#import "MENetworking.h"

@interface MENetworkServer ()

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic ,strong) NSMutableDictionary *requests;

@property (nonatomic ,strong) NSMutableDictionary *downloadResumeDataDict;

@end

@implementation MENetworkServer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.requests = [NSMutableDictionary dictionary];
        
        self.downloadResumeDataDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSInteger)MEcallGETWithParams:(NSDictionary *)params paramsType:(MENetworkParamsType)paramsType path:(NSString *)path config:(MERequestConfig *)config success:(MECallback)success fail:(MECallback)fail{
    
    NSMutableURLRequest *request = [[MENetworkOffice shareOffice] MEParamsToRequestWithPath:path pramas:params paramsType:paramsType requestType:MERequestType_GET config:config];
    
    NSNumber *number = [self MEcallApiWithRequest:request success:success fail:fail];
    
    return number.integerValue;
}

- (NSInteger)MEcallPOSTWithParams:(NSDictionary *)params paramsType:(MENetworkParamsType)paramsType path:(NSString *)path config:(MERequestConfig *)config success:(MECallback)success fail:(MECallback)fail{
    
    NSMutableURLRequest *request = [[MENetworkOffice shareOffice] MEParamsToRequestWithPath:path pramas:params paramsType:paramsType requestType:MERequestType_Post config:config];
    
    NSNumber *number = [self MEcallApiWithRequest:request success:success fail:fail];
    
    return number.integerValue;
}



- (NSInteger)MECallServeWithRequestType:(MERequestType)requestType Params:(NSDictionary *)params paramsType:(MENetworkParamsType)paramsType path:(NSString *)path config:(MERequestConfig *)config success:(MECallback)success fail:(MECallback)fail{
    
    NSMutableURLRequest *request = [[MENetworkOffice shareOffice] MEParamsToRequestWithPath:path pramas:params paramsType:paramsType requestType:requestType config:config];
    
    NSNumber *number = [self MEcallApiWithRequest:request success:success fail:fail];
    
    return number.integerValue;
}

- (NSInteger)MECallServeWithConfig:(MERequestConfig *)config Params:(NSDictionary *)params path:(NSString *)path success:(MECallback)success fail:(MECallback)fail{
    
    NSMutableURLRequest *request = [[MENetworkOffice shareOffice] MEParamsToRequestWithPath:path pramas:params paramsType:config.request_ParamsType requestType:config.request_Type config:config];
    
    NSNumber *number = [self MEcallApiWithRequest:request success:success fail:fail];
    
    return number.integerValue;
}

- (NSNumber *)MEcallApiWithRequest:(NSURLRequest *)request success:(MECallback)success fail:(MECallback)fail{
    
    long long startSeconds = [self getNowTime];
    
    __block NSURLSessionDataTask *dataTask = nil;

    NSString *path = request.URL.absoluteString;
    if ([MERequestAPIConfig needToDealWithPath:path]) {
        [MERequestAPIConfig printRequest:path];
    } else {
        Log_SNTAPI(@"%@",[MERequestAPIConfig requestWithPath:path]);
    }
    
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.requests removeObjectForKey:requestID];
        long long endSeconds = [self getNowTime] ;
        if (error) {
            
            MEURLResponse *ruturnRes = [[MEURLResponse alloc] initWithResponseString:responseObject requestId:requestID request:request error:error];
            
            //            NSLog(@"MENetworkServe ---%@",error);
            Log_ERROR(@"%@ %lld %@ ",[MERequestAPIConfig requestWithPath:path],endSeconds-startSeconds,error);
            fail?fail(ruturnRes):nil;
        } else {
            // 检查http response是否成立。
            MEURLResponse *ruturnRes = [[MEURLResponse alloc] initWithResponseString:responseObject requestId:requestID request:request error:nil];
            
            //            NSLog(@"MENetworkServe ---%@",responseObject);
            if ([MERequestAPIConfig needToDealWithPath:path]) {
                [MERequestAPIConfig printLogRequestPath:path result:responseObject[@"result"] requestTime:endSeconds - startSeconds];
            } else {
                Log_REVAPI(@"%@  %lld %@",[MERequestAPIConfig requestWithPath:path],endSeconds-startSeconds,responseObject);
            }
            
            success?success(ruturnRes):nil;
        }
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    
    self.requests[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}

- (NSInteger)MEcallDOWNLOADRequestWithDownloadParams:(NSDictionary *)downloadParams requestPath:(NSString *)requestPath paramsType:(MENetworkParamsType)paramsType config:(MERequestConfig *)config progress:(void(^)(NSProgress *progress))progress success:(MECallback)success fail:(MECallback)fail;{
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.timeoutIntervalForRequest = config.apiNetworkingTimeoutSeconds;
    
    AFHTTPSessionManager *downSessionManger = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:sessionConfig];
    
    NSString *toFilePath = downloadParams[@"toFilePath"];
    
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestPath]];
    
    NSURLSessionDownloadTask *downloadTask;
    
    id resumeData = self.downloadResumeDataDict[requestPath];
    
    if (requestPath) {
        
        [self.downloadResumeDataDict removeObjectForKey:requestPath];
    }else{
        
        Log_INFO(@"requestPath is nil %@",requestPath);
        
    }
    
    if (resumeData==nil || [resumeData isKindOfClass:[NSString class]]) {
        
        downloadTask = [self startDownloadWithManager:downSessionManger Request:request toFilePath:toFilePath progress:progress success:success fail:fail];
    }else{
        
        NSLog(@"download with resumeData: %@",requestPath);
        
        downloadTask = [self startDownloadWithResumeData:resumeData Manager:downSessionManger Request:request toFilePath:toFilePath progress:progress success:success fail:fail];
    }
    
    NSNumber *requestId = @([downloadTask taskIdentifier]);
    
    self.requests[requestId] = downloadTask;
    [downloadTask resume];
    
    
    return requestId.integerValue;
}

-(NSURLSessionDownloadTask *)startDownloadWithManager:(AFHTTPSessionManager *)downSessionManger Request:(NSURLRequest *)request toFilePath:(NSString *)filePath progress:(void(^)(NSProgress *progress))progress success:(MECallback)success fail:(MECallback)fail{
    
    __block NSURLSessionDownloadTask *downloadTask = [downSessionManger downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress) {
            progress(downloadProgress);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {//下载失败
            
            MEURLResponse *urlRespone = [[MEURLResponse alloc]initWithResponseString:nil requestId:@([downloadTask taskIdentifier]) request:request error:error];
            
            
            fail?fail(urlRespone):nil;
            
        }else{//下载成功
            
            MEURLResponse *urlRespone = [[MEURLResponse alloc]initWithResponseString:filePath.path requestId:@([downloadTask taskIdentifier]) request:request];
            
            success?success(urlRespone):nil;
            
        }
        
    }];
    
    return downloadTask;
}

-(NSURLSessionDownloadTask *)startDownloadWithResumeData:(NSData *)resumeData Manager:(AFHTTPSessionManager *)downSessionManger Request:(NSURLRequest *)request toFilePath:(NSString *)filePath progress:(void(^)(NSProgress *progress))progress success:(MECallback)success fail:(MECallback)fail{
    
    __block NSURLSessionDownloadTask *downloadTask = [downSessionManger downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress) {
            progress(downloadProgress);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {//下载失败
            
            MEURLResponse *urlRespone = [[MEURLResponse alloc]initWithResponseString:nil requestId:@([downloadTask taskIdentifier]) request:request error:error];
            
            
            fail?fail(urlRespone):nil;
            
        }else{//下载成功
            
            MEURLResponse *urlRespone = [[MEURLResponse alloc]initWithResponseString:filePath.path requestId:@([downloadTask taskIdentifier]) request:request];
            
            success?success(urlRespone):nil;
            
        }
        
    }];
    
    return downloadTask;
}

- (NSInteger)MEcallUPLOADRequestWithUploadParams:(NSDictionary *)uploadParams requestPath:(NSString *)requestPath paramsType:(MENetworkParamsType)paramsType config:(MERequestConfig *)config progress:(void(^)(NSProgress *progress))progress success:(MECallback)success fail:(MECallback)fail{
    
    self.sessionManager.requestSerializer.timeoutInterval = config.apiNetworkingTimeoutSeconds;
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSString *resourcePath = uploadParams[@"resourcePath"];
    NSString *mimeType = uploadParams[@"mimeType"];
    NSString *fileName = uploadParams[@"fileName"];
    NSDictionary *requestParams = uploadParams[@"requestParam"];
    
    __block NSURLSessionDataTask *uploadTask = [self.sessionManager POST:requestPath parameters:requestParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *data = [NSData dataWithContentsOfFile:resourcePath];
        
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress) {
            
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        MEURLResponse *urlRespone = [[MEURLResponse alloc]initWithResponseString:responseObject requestId:@([uploadTask taskIdentifier]) request:nil];
        
        success?success(urlRespone):nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSNumber *requestID = @([task taskIdentifier]);
        [self.requests removeObjectForKey:requestID];
        
        MEURLResponse *urlRespone = [[MEURLResponse alloc]initWithResponseString:nil requestId:@([uploadTask taskIdentifier]) request:nil error:error];
        
        fail?fail(urlRespone):nil;
        
    }];
    
    NSNumber *requestId = @([uploadTask taskIdentifier]);
    
    self.requests[requestId] = uploadTask;
    [uploadTask resume];
    
    return requestId.integerValue;
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSURLSessionDataTask *requestOperation = self.requests[requestID];
    
    if ([requestOperation isKindOfClass:[NSURLSessionDownloadTask class]]) {
        
        NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)requestOperation;
        
        if (downloadTask.state == NSURLSessionTaskStateRunning) {
            
            [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                
                NSString *key = downloadTask.currentRequest.URL.absoluteString;
                
                NSLog(@"download cancle cache resumeData: %@",key);
                
                if (resumeData) {
                    
                    [self.downloadResumeDataDict setObject:resumeData forKey:key];
                }else{
                    
                    [self.downloadResumeDataDict setObject:@"" forKey:key];
                }
                
            }];
        }
    }else{
        
        [requestOperation cancel];
    }
    
    [self.requests removeObjectForKey:requestID];
}

-(AFHTTPSessionManager *)sessionManager{
    
    if (_sessionManager == nil) {
        
        _sessionManager = [[AFHTTPSessionManager alloc] init];
        //申明返回的结果是json类型
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        //如果报接受类型不一致请替换一致text/html或别的
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain",@"text/json",@"text/javascript", nil];
    }
    return _sessionManager;
}


// 获取当前时间
- (long long)getNowTime {
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    long long nowSeconds = interval*1000 ;
    return nowSeconds;
}

@end
