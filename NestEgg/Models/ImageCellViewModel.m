//
//  ImageCellViewModel.m
//  NestEgg
//
//  Created by Ido Mizrachi on 2/11/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

#import "ImageCellViewModel.h"
#import "NestEgg-Swift.h"

@interface ImageCellViewModel()

@end

@implementation ImageCellViewModel

-(instancetype)initWithUrl:(NSString *)url imageHandler:(NestEgg *)imageHandler {
    self = [super init];
    if (self) {
        _url = url;
        _imageHandler = imageHandler;
    }
    return self;
}

-(void)updateImageView:(id)imageView {
    __weak ImageCellViewModel *weakSelf = self;
    [self.imageHandler fetchWithUrl:self.url imageView:imageView completion:^(NSError * _Nullable error) {
        __strong ImageCellViewModel *strongSelf = weakSelf;
        NSLog(@"Done - %@ %@", error, strongSelf.url);
        if (strongSelf.delegate == nil) {
            NSLog(@"nil delegate");
        }
        [strongSelf.delegate viewModelDidUpdate: strongSelf];
    }];
}

@end
