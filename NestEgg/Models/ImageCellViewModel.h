//
//  ImageCellViewModel.h
//  NestEgg
//
//  Created by Ido Mizrachi on 2/11/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NestEgg;
@class ImageCellViewModel;

@protocol ImageCellViewModelDelegate

-(void)viewModelDidUpdate:(ImageCellViewModel *)viewModel;

@end

@interface ImageCellViewModel : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NestEgg *imageHandler;

@property (nonatomic, weak) id<ImageCellViewModelDelegate> delegate;

-(instancetype)initWithUrl:(NSString *)url imageHandler:(NestEgg *)imageHandler;

-(void)updateImageView:(UIImageView *)imageView;

@end
