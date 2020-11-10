//
//  MERequestConfig.h
//  MagicEar
//
//  Created by wangshuguang on 2018/5/7.
//  Copyright © 2018年 liufangyu@mmears.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MERequestAPIConfig : NSObject

/**
 获取接口名称
 
 @param path 接口路径 e.g:http://staging.mmears.com/id/login/pwd
 @return 同意的接口名称 e.g:login_pwd
 */
+ (NSString *)requestWithPath:(NSString *)path;

/**
 是否需要自己处理打印log
 
 @param path 路径
 @return YES 打印 NO 不打印
 */
+ (BOOL)needToDealWithPath:(NSString *)path;
/**
 打印请求的log
 
 @param path 请求的路径
 */
+ (void)printRequest:(NSString *)path;

/**
 打印log
 */
+ (void)printLogRequestPath:(NSString *)path result:(NSDictionary *)result requestTime:(long long)requestTime;

@end


