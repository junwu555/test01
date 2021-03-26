//
//  FTCloud.m
//  RiceBall
//
//  Created by QMY on 2021/3/4.
//

#import "FTCloud.h"
#import "FTHttpNetworkManager.h"
#import "FTCLoudError.h"
#import "FTParameter.h"
#import "FTCloudUtil.h"
#import "FTResponseHandle.h"
#import "FTHeaderExpansion.h"
#import "FTBaseHttpPolicy.h"
#import "FTParameter.h"
#import "NSError+NetworkAbility.h"

@interface FTCloud()
@property (nonatomic ,strong) FTHttpNetworkManager * networkManager;
@end
@implementation FTCloud
#pragma -mark init
+ (instancetype)shardInstance
{
    static FTCloud * cloud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cloud = [FTCloud new];
    });
    return cloud;
}

#pragma -mark Config NetworkManager
- (FTHttpNetworkManager *)networkManager
{
    if (!_networkManager) {
        _networkManager = [[FTHttpNetworkManager alloc] initWithBaseURL:_baseURL httpPolicy:[self configHttpPolicy]];
        //响应序列化统一为JSON处理
        [_networkManager configRequestSerialization:REQUEST_SERIALIZE_JSON];
        [_networkManager configResponseSerialization:RESPONSE_SERIALIZE_JSON];
    }
    return _networkManager;
}

//配置请求序列化器
- (void)configSerialize:(FTSerializeModel *)serializeModel
{
    [self.networkManager configRequestSerialization:serializeModel.requestSerialize];
    [self.networkManager configResponseSerialization:serializeModel.responseSerialize];
}

//配置http策略
- (FTBaseHttpPolicy *)configHttpPolicy
{
    FTBaseHttpPolicy * policy = [FTBaseHttpPolicy new];
    //使用非默认设置
    return policy;
}
//重置BaseURL
- (void)setBaseURL:(NSString *)baseURL
{
    _baseURL = baseURL;
    [self.networkManager resetSessionBaseUrl:baseURL];
}

#pragma -mark Business Request
- (FTTask *)creatRequestWithPath:(NSString *)path
                           param:(nullable NSDictionary *)param
                      streamData:(nullable id<FTStreamDataProtocol>)streamData
                          method:(NetworkURLType)method
                       serialize:(nullable FTSerializeModel *)serialize
                 containLocation:(BOOL)headerContainLocation
                   interLanguage:(FTLanguageInterfaceType)interLanguage
                        progress:(void (^)(NSProgress *uploadProgress))progress
                         success:(void (^)(FTBusinessResponse * response))success
                         failure:(void (^)(NSError *error))failure
{
    
    //判断网络状态
    if (![FTCloudUtil linkToNetWorkShowTint:YES]) {
        failure([NSError getNetworkAbilityError]);
        return nil;
    };
    //配置序列化器
    if (!serialize) [self configSerialize:serialize];
    
    //配置Business Header
    [self.networkManager configHeader: [FTHeaderExpansion getCustomHeaderWithUrl:path isClearNetworkHeaderBool:headerContainLocation]];
    
    //校准path
    NSString * calibPath = [FTParameter calibrationPath:path portType:@"" urlType:method];
    
    //校准param
    NSDictionary * calibParam = [FTParameter calibrationParam:param];
    
    //调用网络组件
    FTTask * task = [self.networkManager requestWithUrl:calibPath parameters:calibParam streamData:streamData requestMethod:method parameterType:(streamData?UPLAOD_TYPE_FILE:UPLOAD_TYPE_NORMAL) progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(FTResponse * response) {
        //解析响应体(只解析响应体与code,不耦合页面处理逻辑)
        FTBusinessResponse * analysisResponse = [FTResponseHandle handleResponse:response.responseBody date:[NSDate date] path:path method:[self httpMethodConvert:method] responseHeader:response.responseHeader language:interLanguage];
        
        analysisResponse.error?failure(analysisResponse.error):success(analysisResponse);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];

  return task;
}

#pragma -mark Convert
- (ENUM_REQUEST_METHOD)httpMethodConvert:(NetworkURLType)urlType
{
    ENUM_REQUEST_METHOD method = 0;
    
    switch (urlType) {
        case NetworkURLPOST:
            method = REQUEST_TYPE_POST;
            break;
            
        case NetworkURLGET:
            method = REQUEST_TYPE_GET;
            break;
            
        case NetworkURLPUT:
            method = REQUEST_TYPE_PUT;
            break;
            
        case NetworkURLDELETE:
            method = REQUEST_TYPE_DELELTE;
            break;
    }
    
    return method;
}


@end
