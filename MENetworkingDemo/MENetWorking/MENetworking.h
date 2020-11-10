//
//  MENetworking.h
//  MENetworkingDemo
//
//  Created by 陈建才 on 2018/7/4.
//  Copyright © 2018年 mmear. All rights reserved.
//

#ifndef MENetworking_h
#define MENetworking_h

#import "MEBaseAPIManager.h"
#import "MEDownOrUploadAPIManger.h"
#import "MENetworkOffice.h"
#import "MERequestConfig.h"
#import "MEURLResponse.h"

#ifndef __OPTIMIZE__

#define NSLog(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s %s:%d行][DEBUG] %s\n",[str UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);}   /*fprintf(stdout,"[%s:%d行] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);*/

#define Log_ERROR(FORMAT, ...) nil

#define Log_INFO(FORMAT, ...) nil

#define Log_REVNT(FORMAT, ...) nil


#define Log_SEVNT(FORMAT, ...) nil

#define Log_AGSDK(FORMAT, ...) nil

#define Log_ZGSDK(FORMAT, ...) nil

#define Log_SNTAPI(FORMAT, ...) nil

#define Log_REVAPI(FORMAT, ...) nil

#define WEBLOG(FORMAT,...) nil

#else

#define NSLog(FORMAT, ...) nil

#define Log_INFO(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [INFO] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}



#define Log_ERROR(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [ERROR] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}


#define Log_REVNT(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [REVNT] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}

#define Log_SEVNT(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [SEVNT] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}

#define Log_AGSDK(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [AGSDK] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}

#define Log_ZGSDK(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [ZGSDK] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}


#define Log_SNTAPI(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [SNTAPI] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}

#define Log_REVAPI(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [REVAPI] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}

#define WEBLOG(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"[%s] [WEBLOG] %s\n",[str UTF8String], [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
fflush(stderr);\
}

#endif

#endif /* MENetworking_h */
