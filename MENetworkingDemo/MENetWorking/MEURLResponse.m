//
//  MEURLResponse.m
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MEURLResponse.h"
#import "NSURLRequest+MENetworking.h"
@interface MEURLResponse ()

//@property (nonatomic, assign, readwrite) MEURLResponseStatus status;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;
@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation MEURLResponse

- (instancetype)initWithResponseString:(id)content requestId:(NSNumber *)requestId request:(NSURLRequest *)request{
    
    self = [super init];
    if (self) {

        self.content = content;
//        self.status = status;
        self.requestId = [requestId integerValue];
        self.request = request;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        self.error = nil;
    }
    return self;
}

- (instancetype)initWithResponseString:(id)content requestId:(NSNumber *)requestId request:(NSURLRequest *)request error:(NSError *)error{
    
    self = [super init];
    if (self) {
        
//        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        self.error = [self errorCodeUnity:error];
        if (content) {
            self.content = content;
        } else {
            self.content = nil;
        }
    }
    return self;
}

-(instancetype)initWithContent:(id)content{
    
    self = [super init];
    if (self) {
    
//        self.status = [self responseStatusWithError:nil];
        self.requestId = 0;
        self.request = nil;
        self.content = content;
        self.isCache = YES;
        self.error = nil;
    }
    return self;
}

-(NSError *)errorCodeUnity:(NSError *)error{
    
    NSDictionary *temp = error.userInfo;
    
    NSHTTPURLResponse *response = temp[@"com.alamofire.serialization.response.error.response"];
    
    if (response) {
        
        NSError *newError = [NSError errorWithDomain:error.domain code:response.statusCode userInfo:error.userInfo];
        
        return newError;
        
    }else{
        
        NSError *tempError = temp[@"NSUnderlyingError"];
        
        NSDictionary *tempDict = tempError.userInfo;
        
        NSHTTPURLResponse *responseInfo = tempDict[@"com.alamofire.serialization.response.error.response"];
        
        if (responseInfo) {
            
            NSError *newError = [NSError errorWithDomain:error.domain code:responseInfo.statusCode userInfo:error.userInfo];
            
            return newError;
        }
    }
    
    return error;
}

//- (MEURLResponseStatus)responseStatusWithError:(NSError *)error
//{
//    if (error) {
//        MEURLResponseStatus result = MEURLResponseStatusErrorNoNetwork;
//        
//        // 除了超时以外，所有错误都当成是无网络
//        if (error.code == NSURLErrorTimedOut) {
//            result = MEURLResponseStatusErrorTimeout;
//        }
//        return result;
//    } else {
//        return MEURLResponseStatusSuccess;
//    }
//}

@end
