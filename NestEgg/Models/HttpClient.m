//
//  HttpClient.m
//  ImageHandler
//
//  Created by Ido Mizrachi on 2/5/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

#import "HttpClient.h"
@import AFNetworking;

@interface HttpClient()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation HttpClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: sessionConfiguration];
        AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];    
        self.manager.responseSerializer = serializer;
    }
    return self;
}

-(void)executeWithRequest:(NestEggHttpRequest *)request response:(void (^)(NestEggHttpResponse * _Nonnull))responseBlock {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: request.url]];
    for (NSString *header in request.headers) {
        [urlRequest setValue:request.headers[header] forHTTPHeaderField:header];
    }
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:urlRequest uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull urlResponse, id  _Nullable responseObject, NSError * _Nullable error) {
        NestEggHttpResponse *response = nil;
        if (error) {
            response = [[NestEggHttpResponse alloc] initWithError: error];
        } else {
            response = [[NestEggHttpResponse alloc] initWithData: responseObject];
        }
        responseBlock(response);
    }];
    [task resume];
    
    
}


@end
