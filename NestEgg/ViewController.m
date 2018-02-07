//
//  ViewController.m
//  ImageHandler
//
//  Created by Ido Mizrachi on 2/5/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

#import "ViewController.h"
#import "NestEgg-Swift.h"
#import "HttpClient.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) NestEgg *imageHandler;


@end

@implementation ViewController

-(NestEgg *)imageHandler {
    if (! _imageHandler) {
        HttpClient *httpClient = [HttpClient new];
        NestEggDefaultCache *cache = [[NestEggDefaultCache alloc] initWithFolder: @"image-handler-cache" timeoutInterval: 20];
        _imageHandler = [[NestEgg alloc] initWithHttpClient:httpClient cache:cache];
    }
    return _imageHandler;
}

- (IBAction)loadImage:(id)sender {
//    __weak typeof(self) weakSelf = self;
    
    
//    [self.imageHandler fetchWithUrl:url completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
//        __strong typeof(self) strongSelf = weakSelf;
//        if (! strongSelf) {
//            return;
//        }
//        if (error) {
//            strongSelf.label.text = @"Error";
//        } else {
//            strongSelf.label.text = @"Done";
//            self.imageView.image = image;
//        }
//    }];
    
    [self fetchImage];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        __strong typeof(self) strongSelf = weakSelf;
//        [strongSelf fetchImage];
//    });
}

-(void)fetchImage {
    __weak typeof(self) weakSelf = self;
    self.label.text = @"Loading...";
    NSString *url = @"http://imaging.nikon.com/lineup/lens/zoom/normalzoom/af-s_dx_18-140mmf_35-56g_ed_vr/img/sample/sample1_l.jpg";
    [self.imageHandler fetchWithUrl:url imageView:self.imageView completion:^(NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (! strongSelf) {
            return;
        }
        if (error) {
            strongSelf.label.text = @"Error";
        } else {
            strongSelf.label.text = @"Done";
        }
    }];
    [self.imageHandler fetchWithUrl:url imageView:self.imageView completion:^(NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (! strongSelf) {
            return;
        }
        if (error) {
            strongSelf.label.text = @"Error";
        } else {
            strongSelf.label.text = @"Done";
        }
    }];
}


@end
