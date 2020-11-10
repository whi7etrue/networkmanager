//
//  testConfigAPIManager.m
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/19.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MENormalAPIManger.h"
#import "MEURLResponse.h"
#import "MENetworkOffice.h"

@interface MENormalAPIManger ()

@end

@implementation MENormalAPIManger

-(BOOL)beforePerformSuccessWithResponse:(MEURLResponse *)response{
    
    if ([super beforePerformSuccessWithResponse:response]) {
            
            NSDictionary *responseObj = response.content;
            
            NSNumber *codeNum = responseObj[@"code"];
            
            if (codeNum.integerValue == 0 ) {
                
                [self.delegate managerCallAPIDidSuccess:self];
                
            }else{
                
                //解析下服务器的error
                self.errorType = MEBaseAPIManagerErrorTypeDefault;
                
                NSString *errorString = [self tips_messageWithResponse:response];
                
                self.errorMessage = errorString;
                
                NSError *error = [NSError errorWithDomain:errorString code:codeNum.integerValue userInfo:nil];
                
                MEURLResponse *ruturnRes = [[MEURLResponse alloc] initWithResponseString:response.content requestId:@(response.requestId) request:response.request error:error];
                
                self.urlResponse = ruturnRes;
                
                [self.delegate managerCallAPIDidFailed:self];
            }
    }
    
    return NO;
}

//- (NSString *)tips_messageWithResponse:(MEURLResponse *)response
//{
//    NSDictionary *dic = response.content;
//    NSString *tips_message = dic[@"result"][@"tips_message"];
//    NSArray *array = [tips_message componentsSeparatedByString:@"|"];
//
//    NSString *tip_message;
//
//    if ([MENetworkOffice shareOffice].roleType == MENetworkRoleType_student) {
//
//       tip_message = array.firstObject;
//    }else{
//
//        tip_message = array.lastObject;
//    }
//
//    if ([tip_message isKindOfClass:[NSString class]] &&  tip_message.length > 0) {
//        return tip_message;
//    } else {
//
//        return @"未知网络错误";
//    }
//}

- (NSString *)tips_messageWithResponse:(MEURLResponse *)response
{
    NSDictionary *dic = response.content;
    
    id messageDict = dic[@"result"];
    
    NSString *tip_message;
    
    if ([messageDict isKindOfClass:[NSDictionary class]]) {
        
        NSString *tips_message = messageDict[@"tips_message"];
        NSArray *array = [tips_message componentsSeparatedByString:@"|"];
        
        if ([MENetworkOffice shareOffice].roleType == MENetworkRoleType_student) {
            
            tip_message = array.firstObject;
        }else{
            
            tip_message = array.lastObject;
        }
    }else if ([messageDict isKindOfClass:[NSString class]]){
        
        return messageDict;
    }
    
    if ([tip_message isKindOfClass:[NSString class]] &&  tip_message.length > 0) {
        return tip_message;
    } else {
        
        if ([MENetworkOffice shareOffice].roleType == MENetworkRoleType_student) {
            
            return @"未知网络错误";
        }
        
        return @"no known network error";
    }
}

@end
