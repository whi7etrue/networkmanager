//
//  TestAPIManager.m
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MEDownOrUploadAPIManger.h"

@interface MEDownOrUploadAPIManger()<MEBaseAPIManagerInterceptor>

@property (nonatomic,assign)MERequestType APIType;
@property (nonatomic,copy)NSString *APIName;

@end

@implementation MEDownOrUploadAPIManger

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}



#pragma mark MEBaseAPIManager delegate
- (NSString *)methodName{
    
    if (self.requestType == MERequestType_Upload) {
        
        return self.APIName;
        
    }else if(self.requestType == MERequestType_Download){
        
        return self.APIName;
        
    }else{
        
       return nil;
        
    }
    
    
}

- (MERequestType)requestType
{
    return self.APIType;
}

-(MENetworkParamsType)paramsType{
    
    return MENetworkParamsType_unicode;
}

- (BOOL)shouldCache
{
    return NO;
}

- (NSInteger)loadDataWithRequestType:(MERequestType)type DownloadPath:(NSString *)downloadPath{
    
    self.APIType = type;
    
    self.APIName = downloadPath;
    
    return [self loadData];
    
}

@end
