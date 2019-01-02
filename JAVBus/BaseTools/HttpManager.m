//
//  HttpManager.m
//  MJLife
//
//  Created by mgfjx on 2018/9/3.
//  Copyright © 2018年 Joseph_Xuan. All rights reserved.
//

#import "HttpManager.h"
#import <AFNetworking/AFNetworking.h>

@interface HttpManager()

@property (nonatomic, strong) AFHTTPSessionManager *manager ;
@property (nonatomic, strong) NSString *baseUrl ;

@end

@implementation HttpManager

static id singleton = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleton = [super allocWithZone:zone];
        });
    }
    return singleton;
}

- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [super init];
    });
    return singleton;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return singleton;
}

+ (instancetype)manager {
    return [[self alloc] init];
}

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        [self buildManager];
    }
    return _manager;
}

- (void)buildManager {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURL *baseUrl = [NSURL URLWithString:self.baseUrl];
    configuration.timeoutIntervalForRequest = 30;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl sessionConfiguration:configuration];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    manager.responseSerializer.acceptableContentTypes =nil;
    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    _manager = manager;
}

#pragma mark - 上传图片
- (void)postUrl:(NSString *)url imageArray:(NSArray *)imageArray fileParmaName:(NSString *)fileParmaName param:(NSDictionary *)param success:(SuccessCallback)success failure:(FailCallback)failure {
    
    [self.manager POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i = 0; i <imageArray.count; i++){
            NSData *imageData;
            NSString *imagetype=@"png";
            
            imageData = UIImageJPEGRepresentation(imageArray[i],1.0);
            if (imageData.length/1024.0 > 150.0){
                imageData = UIImageJPEGRepresentation(imageArray[i], 1024*150.0/(float)imageData.length);
            }
            NSDateFormatter *formmettrt = [[NSDateFormatter alloc]init];
            [formmettrt setDateFormat:@"yyyyMMddHHmmss"];
            NSDate *nowDate=[NSDate date];
            [formmettrt stringFromDate:nowDate];
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
            
            [formData appendPartWithFileData:imageData name:fileParmaName fileName:[NSString stringWithFormat:@"%@-%d.%@", timeSp,i,imagetype] mimeType:[NSString stringWithFormat:@"image/%@", imagetype]];
            
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        // 打印上传进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *string2dic = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error:nil];
        success(string2dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

#pragma mark - 上传图片和语音
- (void)postUrl:(NSString *)url
          param:(NSDictionary *)param
     imageArray:(NSArray *)imageArray
   imgParmaName:(NSString *)imgParmaName
      audioFile:(NSString *)audioFile
 audioParmaName:(NSString *)audioParmaName
        success:(SuccessCallback)success
        failure:(FailCallback)failure {
    
    [self.manager POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i = 0; i <imageArray.count; i++){
            NSData *imageData;
            NSString *imagetype=@"png";
            
            imageData = UIImageJPEGRepresentation(imageArray[i],1.0);
            if (imageData.length/1024.0 > 150.0){
                imageData = UIImageJPEGRepresentation(imageArray[i], 1024*150.0/(float)imageData.length);
            }
            NSDateFormatter *formmettrt = [[NSDateFormatter alloc]init];
            [formmettrt setDateFormat:@"yyyyMMddHHmmss"];
            NSDate *nowDate=[NSDate date];
            [formmettrt stringFromDate:nowDate];
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
            
            [formData appendPartWithFileData:imageData name:imgParmaName fileName:[NSString stringWithFormat:@"%@-%d.%@", timeSp,i,imagetype] mimeType:[NSString stringWithFormat:@"image/%@", imagetype]];
            
        }
        
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate new] timeIntervalSince1970]];
        NSData *audioData = [[NSData alloc] initWithContentsOfFile:audioFile];
        [formData appendPartWithFileData:audioData name:audioParmaName fileName: [NSString stringWithFormat:@"%@.mp3", timeSp] mimeType:@"amr/mp3/wmr"];
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        // 打印上传进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *string2dic = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error:nil];
        success(string2dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)startPostUrl:(NSString *)url param:(NSDictionary *)param success:(SuccessCallback)success failure:(FailCallback)failure {
    
    [self.manager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            success(jsonDict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [PublicDialogManager showText:@"接口错误" inView:[UIApplication sharedApplication].keyWindow.rootViewController.view duration:1.0];
        failure(error);
    }];
}

- (void)startGetUrl:(NSString *)url param:(NSDictionary *)param success:(SuccessCallback)success_block failure:(FailCallback)failure_block {
    [self.manager GET:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success_block(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure_block(error);
    }];
}

/**
 根据番号从Avgle获取预览视频

 @param code 番号
 */
- (void)getVideoByCode:(NSString *)code SuccessCallback:(SuccessCallback)success FailCallback:(FailCallback)failed {
    NSString *url = [NSString stringWithFormat:@"https://api.avgle.com/v1/search/%@/0", code];
    [self startGetUrl:url param:nil success:^(id resultDict) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:resultDict options:NSJSONReadingAllowFragments error:nil];
        success(jsonDict);
    } failure:failed];
}

@end
