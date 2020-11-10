//
//  MENetworkOffice.h
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MERequestConfig.h"

@class MENetworkServer,MERequestConfig;

#define DefaulErrorString @"数据请求失败,请稍后重试"
#define loadingErrorString @"正在请求中"
#define NoContentErrorString @"好像没有内容哦，重试一下吧"
#define ParamsErrorString @"参数错误，重试一下吧"
#define TimeoutErrorString @"网络连接超时,请检查网络连接"
#define NoNetWorkErrorString @"网络已断开，请检查网络，稍后重试"

#define DefaulErrorStringT @"Cannot access to data, please try again"
#define loadingErrorStringT @"Loading....."
#define NoContentErrorStringT @"No Content,please try again"
#define ParamsErrorStringT @"Parameter error,please try again"
#define TimeoutErrorStringT @"The request timed out"
#define NoNetWorkErrorStringT @"Please check the network and try again later"

typedef NS_ENUM(NSUInteger, MERequestMethodNameType) {
    MERequestMethodNameType_courseDownLoadInfo, ///yosemite/courseware/student_download
    MERequestMethodNameType_checkCourseInfo, ///yosemite/classroom/info
    MERequestMethodNameType_getHelpDataInfo, ///yosemite/issue/list
    MERequestMethodNameType_getClassroomToken,///client/classroom/token
    MERequestMethodNameType_getClassroomState,///client/classroom/status
    MERequestMethodNameType_appAPIHostSettingURL,///yosemite/hosts
    MERequestMethodNameType_newVersionInfoURL,///yosemite/file/latest_version
    MERequestMethodNameType_loginURL,///id/login/pwd
    MERequestMethodNameType_registerURL,///id/register/phone
    MERequestMethodNameType_resetPwdURL,///id/resetpwd
    MERequestMethodNameType_phoneCheckURL,///id/phone/check
    MERequestMethodNameType_registerCodeURL,///id/register/code
    MERequestMethodNameType_resetpwdCodeURL,///id/resetpwd/code
    MERequestMethodNameType_studentnfoURL,///yosemite/student_info
    MERequestMethodNameType_previewsInfoURL,///previews/v1/info"
    MERequestMethodNameType_previewsScoreSubmitURL,///previews/v1/score/submit
    MERequestMethodNameType_studentEvaluationURL,///yosemite/student/evaluation
    MERequestMethodNameType_createOrderURL,///pay/api/create_order_client
    MERequestMethodNameType_payInfoURL,///pay/api/pay_info_client
    MERequestMethodNameType_successPaidURL,///pay/api/client_success_paid
    MERequestMethodNameType_aboutClassURL,///api/course/booking
    MERequestMethodNameType_postAboutClassURL,///api/course/book
    MERequestMethodNameType_checkDeviceURL,///yosemite/facility/add
    MERequestMethodNameType_latestVersionURL,///yosemite/file/latest_version
    MERequestMethodNameType_checkAppStoreVersionURL,///itunes.apple.com/lookup
    MERequestMethodNameType_checkTokenURL,///id/login/check
    MERequestMethodNameType_courseConfigURL,///api/course/server/config
    MERequestMethodNameType_courseListURL,///api/course/info/list
    MERequestMethodNameType_getSettingGateURL,///yosemite/triggers
    MERequestMethodNameType_editInfoUrl,///yosemite/student_info/update
    MERequestMethodNameType_getOnceTokenUrl,///mservice/token-generator
    MERequestMethodNameType_addEventTrackingUrl,///shence/addEvent
    MERequestMethodNameType_logoutUrl,///id/logout
    MERequestMethodNameType_padSetting,///yosemite/getpadseeting
    MERequestMethodNameType_teacherInfoURL,///api/teacher/teacher_info
};

typedef NS_ENUM(NSUInteger, MENetworkRoleType) {
    MENetworkRoleType_teacher,
    MENetworkRoleType_student,
};

@class MEBaseAPIManager;

@interface MENetworkOffice : NSObject

+(instancetype)shareOffice;

//学生角色还是老师角色  设置host
@property (nonatomic ,assign) MENetworkRoleType roleType;

//发起网络请求的serve
@property (nonatomic ,strong) MENetworkServer *networkServe;

//请求需要缓存的时候  会存放在这
@property (nonatomic ,strong) NSCache *responseCache;

//错误提示
@property (nonatomic,strong) NSArray *errorStringArr;

//是否有网络
@property (nonatomic, assign, readonly) BOOL isReachable;

@property (nonatomic ,copy) NSString *host;

//获取客户端版本新加字段  YES 是测试
@property (nonatomic ,strong) NSNumber *versionTest;

//所有请求参数的公有部分  没有就不用传
@property (nonatomic ,copy) NSDictionary *extraParmas;

//请求头的内容  @"X-DEVICE-INFO"  @"User-Agent"
@property (nonatomic ,copy) NSDictionary *extraHttpHeaderParmas;

//没有网络时发起的请求  需要网络恢复时重试的请求  调用这个方法存储或者删除
- (void)networkResumeRetryRequestsAddRequest:(MEBaseAPIManager *)manager;
- (void)networkResumeRetryRequestsRemoveRequest:(MEBaseAPIManager *)manager;

+ (MERequestConfig *)fetchConfigWitMethodNameType:(MERequestMethodNameType)nameType;

-(NSMutableURLRequest *)MEParamsToRequestWithPath:(NSString *)path pramas:(NSDictionary *)params paramsType:(MENetworkParamsType)paramsType requestType:(MERequestType)requestType config:(MERequestConfig *)config;

-(void)setHttpHeaderCookie:(NSString *)cookie;

@end
