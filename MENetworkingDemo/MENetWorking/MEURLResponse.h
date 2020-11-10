//
//  MEURLResponse.h
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM(NSUInteger, MEURLResponseStatus)
//{
//    MEURLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的CTAPIBaseManager来决定。
//    MEURLResponseStatusErrorTimeout,
//    MEURLResponseStatusErrorNoNetwork // 默认除了超时以外的错误都是无网络错误。
//};

@interface MEURLResponse : NSObject

//@property (nonatomic, assign, readonly) MEURLResponseStatus status;
@property (nonatomic, copy, readonly) id content;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy, readonly) NSURLRequest *request;

@property (nonatomic, copy) NSDictionary *requestParams;

@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic, assign, readonly) BOOL isCache;

//下载专用属性
@property (nonatomic,copy)NSString *filePath;


- (instancetype)initWithResponseString:(id)content requestId:(NSNumber *)requestId request:(NSURLRequest *)request;

- (instancetype)initWithResponseString:(id)content requestId:(NSNumber *)requestId request:(NSURLRequest *)request error:(NSError *)error;

-(instancetype)initWithContent:(id)content;

@end
