//
//  MENetworkServe.h
//  METestAPIManager
//
//  Created by 陈建才 on 2018/5/17.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MERequestConfig.h"

@class MEURLResponse;

typedef void(^MECallback)(MEURLResponse *response);

@interface MENetworkServer : NSObject

- (NSInteger)MECallServeWithRequestType:(MERequestType)requestType Params:(NSDictionary *)params paramsType:(MENetworkParamsType)paramsType path:(NSString *)path config:(MERequestConfig *)config success:(MECallback)success fail:(MECallback)fail;

- (NSInteger)MECallServeWithConfig:(MERequestConfig *)config Params:(NSDictionary *)params path:(NSString *)path success:(MECallback)success fail:(MECallback)fail;

- (NSInteger)MEcallDOWNLOADRequestWithDownloadParams:(NSDictionary *)downloadParams requestPath:(NSString *)requestPath paramsType:(MENetworkParamsType)paramsType config:(MERequestConfig *)config progress:(void(^)(NSProgress *progress))progress success:(MECallback)success fail:(MECallback)fail;

- (NSInteger)MEcallUPLOADRequestWithUploadParams:(NSDictionary *)uploadParams requestPath:(NSString *)requestPath paramsType:(MENetworkParamsType)paramsType config:(MERequestConfig *)config progress:(void(^)(NSProgress *progress))progress success:(MECallback)success fail:(MECallback)fail;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

@end
