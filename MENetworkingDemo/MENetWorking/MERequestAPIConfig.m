//
//  MERequestConfig.m
//  MagicEar
//
//  Created by wangshuguang on 2018/5/7.
//  Copyright © 2018年 liufangyu@mmears.com. All rights reserved.
//

#import "MERequestAPIConfig.h"
#import "MENetworking.h"

@implementation MERequestAPIConfig

+ (NSString *)requestWithPath:(NSString *)path {
    
    NSDictionary *dic = [self configPath];
    NSAssert(path != nil, @"path is nil");
    
    NSURL *url = [NSURL URLWithString:path];
    
    NSDictionary *configDic = dic[url.path];
    
    NSString *requestPath = configDic[@"host"];
    
    return requestPath;
}

+ (BOOL)needToDealWithPath:(NSString *)path {
    BOOL isNeed = NO;
    if ([path containsString:@"/client/classroom/status"]) {
        isNeed = YES;
    } else if ([path containsString:@"/previews/v1/score/submit"]) {
        isNeed = YES;
    } else if ([path containsString:@"/yosemite/issue/list"]) {
        isNeed = YES;
    } else if ([path containsString:@"/lookup"]) {
        isNeed = YES;
    } else if ([path containsString:@"/shence/addEvent"]) {
        isNeed = YES;
    }
    return isNeed;
}

+ (void)printRequest:(NSString *)path {
    
    if ([path containsString:@"/client/classroom/status"]) {
        Log_SNTAPI(@"%@",[self requestWithPath:path]);
    } else if ([path containsString:@"/previews/v1/score/submit"]) {
        Log_SNTAPI(@"%@",@"Get_PreviewsSubmit");
    }
}

+ (void)printLogRequestPath:(NSString *)path result:(NSDictionary *)result requestTime:(long long)requestTime {
    if ([path containsString:@"/client/classroom/status"]) {
        Log_REVAPI(@"%@ %tu %@,%@,%@,%@",[self requestWithPath:path],requestTime,result[@"classroomId"],result[@"classroom"],result[@"students"],result[@"teacher"]);
    } else if ([path containsString:@"/previews/v1/score/submit"]) {
        Log_REVAPI(@"%@ %tu %@",@"Get_PreviewsSubmit",requestTime,result);
    } else if ([path containsString:@"/yosemite/issue/list"] || [path containsString:@"/lookup"]) {
        
    }
}

+ (NSDictionary *)configPath {
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"MENetworkOffice" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:configPath];
    return dic;
}

@end


