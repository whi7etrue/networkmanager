//
//  MEDataCacheObject.m
//  MagicEars_student_ipad
//
//  Created by 陈建才 on 2018/5/18.
//  Copyright © 2018年 mmear. All rights reserved.
//

#import "MEDataCacheObject.h"
#import "MENetworkOffice.h"

@interface MEDataCacheObject ()

@property (nonatomic ,strong, readwrite) id content;

@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation MEDataCacheObject

- (BOOL)isEmpty
{
    return self.content == nil;
}

- (BOOL)isOutdated
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return timeInterval > self.effectiveDuration ;
}

-(void)setEffectiveDuration:(NSTimeInterval)effectiveDuration{
    
    if (effectiveDuration>0) {
        
        _effectiveDuration = effectiveDuration;
    }
}

- (void)setContent:(id)content
{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}

#pragma mark - life cycle
- (instancetype)initWithContent:(NSData *)content
{
    self = [super init];
    if (self) {
        self.content = content;
        
        self.effectiveDuration = 5 * 60;
    }
    return self;
}

+ (id)fetchCachedDataWithMethodName:(NSString *)methodName andParams:(NSDictionary *)params{
    
    NSString *key = [self keyWithMethodName:methodName andParams:params];
    
    NSLog(@"cache path ----%@",key);
    
    MEDataCacheObject *cache = [[MENetworkOffice shareOffice].responseCache objectForKey:key];
    
    if (cache == nil) {
        
        return nil;
    }else{
        
        if (cache.isOutdated || cache.isEmpty) {
            
            [[MENetworkOffice shareOffice].responseCache removeObjectForKey:key];
            return nil;
        }
    }
    
    return cache.content;
}

+ (NSString *)keyWithMethodName:(NSString *)methodName andParams:(NSDictionary *)params{
    
    return [NSString stringWithFormat:@"%@%@", methodName, [self CT_urlParamsStringSignature:NO withParams:params]];
}

+ (NSString *)CT_urlParamsStringSignature:(BOOL)isForSignature withParams:(NSDictionary *)params{
    
    NSArray *sortedArray = [self CT_transformedUrlParamsArraySignature:isForSignature withParams:params];
    return [self CT_paramsStringWithArray:sortedArray];
}

+ (NSString *)CT_paramsStringWithArray:(NSArray *)array
{
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSArray *sortedParams = [array sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([paramString length] == 0) {
            [paramString appendFormat:@"%@", obj];
        } else {
            [paramString appendFormat:@"&%@", obj];
        }
    }];
    
    return paramString;
}

/** 转义参数 */
+ (NSArray *)CT_transformedUrlParamsArraySignature:(BOOL)isForSignature withParams:(NSDictionary *)params{
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        if (!isForSignature) {
            obj = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)obj,  NULL,  (CFStringRef)@"!*'();:@&;=+$,/?%#[]",  kCFStringEncodingUTF8));
        }
        if ([obj length] > 0) {
            [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    NSArray *sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return sortedResult;
}

@end
