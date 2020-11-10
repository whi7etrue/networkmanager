//
//  MEDataCacheObject.h
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEDataCacheObject : NSObject

@property (nonatomic ,strong, readonly) id content;

@property (nonatomic, copy, readonly) NSDate *lastUpdateTime;

@property (nonatomic, assign, readonly) BOOL isOutdated;
@property (nonatomic, assign, readonly) BOOL isEmpty;

@property (nonatomic ,assign) NSTimeInterval effectiveDuration;

+ (id)fetchCachedDataWithMethodName:(NSString *)methodName andParams:(NSDictionary *)params;

+ (NSString *)keyWithMethodName:(NSString *)methodName andParams:(NSDictionary *)params;

- (instancetype)initWithContent:(NSData *)content;

@end
