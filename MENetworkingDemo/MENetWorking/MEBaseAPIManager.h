//
//  MEBaseAPIManager.h
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MENetworkOffice.h"
#import "MENetworkServer.h"
#import "MEURLResponse.h"

@class MEBaseAPIManager,MEURLResponse;

static NSString * const kMEBaseAPIManagerRequestID = @"kMEBaseAPIManagerRequestID";

typedef NS_ENUM (NSUInteger, MEBaseAPIManagerErrorType){
    MEBaseAPIManagerErrorTypeDefault = 0,       //默认的失败类型,
    MEBaseAPIManagerErrorTypeSuccess = 1,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    MEBaseAPIManagerErrorTypeNoContent = 2,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    MEBaseAPIManagerErrorTypeParamsError = 3,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    MEBaseAPIManagerErrorTypeTimeout = 4,       //请求超时。
    MEBaseAPIManagerErrorTypeNoNetWork = 5,      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    MEBaseAPIManagerErrorTypeNetWorkResume = 6   //网络状态恢复时  重新请求网络
    
};

#pragma mark  业务层实现代理
@protocol MEBaseAPIManagerCallBackDelegate <NSObject>
@required
- (void)managerCallAPIDidSuccess:(MEBaseAPIManager *)manager;
- (void)managerCallAPIDidFailed:(MEBaseAPIManager *)manager;

@optional

- (void)managerCallAPIWithManger:(MEBaseAPIManager *)manger netWorkProgress:(NSProgress *)progress;

@end

//让manager能够获取调用API所需要的数据
//@protocol MEBaseAPIManagerParamSource <NSObject>

/**
 此回调设置正常GET或者POST参数无限制
 此回调用来设置上传或者下载接口的基本配置时,要注意格式是固定的
 上传接口固定参数格式:
 
 @{
 
     @"resourcePath":@"上传的资源路径",
     @"mimeType":@"上传的数据类型",
     @"fileName":@"上传文件的命名"
     @"requestParam":@{
        //上传需要带上的request参数
         @"参数":@"参数"
        ...
     }
 
 }
 
 下载接口的规定参数格式:
 
 @{
 
     @"toFilePath":@"下载保存到本地的路径,这里包括了文件名的设置",
     @"requestParam":@{
 
         //下载需要带上的request参数
         @"参数":@"参数"
         ...
 
     }
 
 }
 
 
 */

//@required
//
//- (NSDictionary *)paramsForApi:(MEBaseAPIManager *)manager;
//
//@end

@protocol MEBaseAPIManagerInterceptor <NSObject>

@optional
- (BOOL)manager:(MEBaseAPIManager *)manager beforePerformSuccessWithResponse:(MEURLResponse *)response;
- (void)manager:(MEBaseAPIManager *)manager afterPerformSuccessWithResponse:(MEURLResponse *)response;

- (BOOL)manager:(MEBaseAPIManager *)manager beforePerformFailWithResponse:(MEURLResponse *)response;
- (void)manager:(MEBaseAPIManager *)manager afterPerformFailWithResponse:(MEURLResponse *)response;

- (BOOL)manager:(MEBaseAPIManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(MEBaseAPIManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end

#pragma mark  子类实现代理
@protocol MEBaseAPIManager <NSObject>

@required
- (NSString *)methodName;
- (MERequestType)requestType;
- (MENetworkParamsType)paramsType;
- (BOOL)shouldCache;

@optional
- (NSDictionary *)reformParams:(NSDictionary *)params;

@end

@protocol MEBaseAPIManagerValidator <NSObject>
@required

- (BOOL)manager:(MEBaseAPIManager *)manager isCorrectWithCallBackData:(NSDictionary *)data;

- (BOOL)manager:(MEBaseAPIManager *)manager isCorrectWithParamsData:(NSDictionary *)data;
@end

@protocol MEBaseAPIManagerAutoTry <NSObject>

-(BOOL)shouldAutoTry;

-(NSArray *)tryWithTimeouts;

@end

@protocol MEBaseAPIManagerNetworkResumeAutoTry <NSObject>

-(BOOL)netWorkResumeShouldAutoTry;

@end

@interface MEBaseAPIManager : NSObject

@property (nonatomic, weak) id<MEBaseAPIManagerCallBackDelegate> delegate;
//@property (nonatomic, weak) id<MEBaseAPIManagerParamSource> paramSource;
@property (nonatomic, weak) NSObject<MEBaseAPIManager> *child; //里面会调用到NSObject的方法，所以这里不用id
@property (nonatomic, weak) id<MEBaseAPIManagerValidator> validator;
@property (nonatomic, weak) id<MEBaseAPIManagerInterceptor> interceptor;
@property (nonatomic ,weak) id<MEBaseAPIManagerAutoTry> autoTry;
@property (nonatomic ,weak) id<MEBaseAPIManagerNetworkResumeAutoTry> networkAutoTry;

@property (nonatomic ,copy) NSDictionary *params;

@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, assign) MEBaseAPIManagerErrorType errorType;
@property (nonatomic, strong) MEURLResponse *urlResponse;

@property (nonatomic, assign, readonly) BOOL isReachable;
@property (nonatomic, assign, readonly) BOOL isLoading;

-(instancetype)initWithAPIType:(MERequestMethodNameType)methodNameType;

//子类重写此方法  可以拦截父类的
- (BOOL)beforePerformSuccessWithResponse:(MEURLResponse *)response;

- (BOOL)beforePerformFailWithResponse:(MEURLResponse *)response;


- (void)setRequestConfigRequestType:(MERequestType)type;
- (void)setRequestConfigMethodName:(NSString *)newMethodName;
- (void)setRequestConfigTimeouts:(NSDictionary *)timeoutConfig;
- (void)setRequestConfigRequestParamsType:(MENetworkParamsType)type;

- (NSInteger)loadData;

- (void)cancelRequest;

- (void)cleanData;


@end
