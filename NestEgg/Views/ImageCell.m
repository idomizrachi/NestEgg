//
//  ImageCell.m
//  NestEgg
//
//  Created by Ido Mizrachi on 2/10/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

#import "ImageCell.h"
#import "ImageCellViewModel.h"
@import glucose;

@interface ImageCell()<ImageCellViewModelDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ImageCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview: self.imageView];
        [self setupConstraints];
    }
    return self;
}

-(void)setupConstraints {
    [self.imageView edgesToView: self.contentView];
}

-(void)setViewModel:(ImageCellViewModel *)viewModel {
    _viewModel = viewModel;
    _viewModel.delegate = self;
}

-(void)prepareForDisplay {
    NSLog(@"Loading %@", self.viewModel.url);
    [self.viewModel updateImageView: self.imageView];
}

/*
-(void)setUrl:(NSString *)url {
    _url = url;
    [self.imageHandler fetchWithUrl:url imageView:self.imageView completion:^(NSError * _Nullable error) {
        NSLog(@"Done - %@", url);
    }];
}
*/

-(UIImageView *)imageView {
    if (! _imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}


-(void)viewModelDidUpdate:(ImageCellViewModel *)viewModel {
    [self.imageView setNeedsDisplay];
}

@end
