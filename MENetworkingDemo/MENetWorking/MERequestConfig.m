//
//  MERequestParams.m
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/17.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MERequestConfig.h"

@implementation MERequestConfig

-(NSTimeInterval)apiNetworkingTimeoutSeconds{
    
    if (_apiNetworkingTimeoutSeconds <= 0) {
        
        return 10;
    }
    
    return _apiNetworkingTimeoutSeconds;
}

@end
