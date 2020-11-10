//
//  MERequestParams.h
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/17.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MENetworkParamsType) {
    MENetworkParamsType_unicode,
    MENetworkParamsType_jason,
};

typedef NS_ENUM(NSUInteger, MERequestType) {
    MERequestType_GET,
    MERequestType_Post,
    MERequestType_Put,
    MERequestType_Download,
    MERequestType_Upload
};

@interface MERequestConfig : NSObject

@property (nonatomic ,copy) NSString *request_methodName;

//0:unicode 1:jason
@property (nonatomic ,assign) MENetworkParamsType request_ParamsType;

//0:GET 1:post
@property (nonatomic ,assign) MERequestType request_Type;

@property (nonatomic, assign) BOOL shouldCache;
@property (nonatomic, assign) NSTimeInterval cacheOutdateTimeSeconds;

@property (nonatomic, assign) NSTimeInterval apiNetworkingTimeoutSeconds;

@property (nonatomic ,assign) BOOL shouldAutoTry;

@property (nonatomic ,copy) NSArray *tryTimeouts;

@property (nonatomic ,assign) BOOL networkResumeShouldAutoTry;

@end
