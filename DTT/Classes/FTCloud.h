//
//  FTCloud.h
//  RiceBall
//
//  Created by QMY on 2021/3/4.
//

#import <Foundation/Foundation.h>
#import "FTUploadData.h"
#import "FTBusinessResponse.h"
#import "FTTask.h"
#import "FTBusinessMacro.h"
#import "FTSerializeModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FTCloud : NSObject

/**Single Instance*/
+(instancetype) shardInstance;

/**resetBaseURL(act on environment change)*/
@property (nonatomic ,copy) NSString * baseURL;


/** Business Request Interface
* @param path http path or url
* @param param request param(NSDictionary)
* @param streamData Image、Audio or Video Stream
* @param method http method
* @param headerContainLocation Http Header is Contain Location Info
* @param interLanguage Interface Langurage Type
* @param progress progress handle(act on upload)
* @param success success handle
* @param failure failure handle
* @return FTTask Request Task(cancle task)
*/
- (FTTask *)creatRequestWithPath:(NSString *)path
                           param:(nullable NSDictionary *)param
                      streamData:(nullable id<FTStreamDataProtocol>)streamData
                          method:(NetworkURLType)method
                       serialize:(nullable FTSerializeModel *)serialize
                 containLocation:(BOOL)headerContainLocation
                   interLanguage:(FTLanguageInterfaceType)interLanguage
                        progress:(void (^)(NSProgress *uploadProgress))progress
                         success:(void (^)(FTBusinessResponse * response))success
                         failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
