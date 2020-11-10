//
//  NSURLRequest+MENetworking.m
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/22.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "NSURLRequest+MENetworking.h"
#import <objc/runtime.h>

static void *MENetworkingRequestParams;

@implementation NSURLRequest (MENetworking)

- (void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &MENetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams
{
    return objc_getAssociatedObject(self, &MENetworkingRequestParams);
}

@end
