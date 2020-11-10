//
//  TestAPIManager.h
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MEBaseAPIManager.h"

@interface MEDownOrUploadAPIManger : MEBaseAPIManager <MEBaseAPIManager>

/**
 下载和上传要调用子类的方法
 
 @param type 下载或者上传请求类型
 @param downloadPath 下载的请求连接
 */

- (NSInteger)loadDataWithRequestType:(MERequestType)type DownloadPath:(NSString *)downloadPath;

@end
