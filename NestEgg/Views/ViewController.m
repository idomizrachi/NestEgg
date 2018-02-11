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
#import "ImageCell.h"
#import "ImageCellViewModel.h"
@import glucose;

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) NestEgg *imageHandler;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<ImageCellViewModel *> *items;


@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview: self.collectionView];
    [self setupConstraints];
    [self.imageHandler preheatWithUrl: @"http://myanmareiti.org/sites/default/files/sample-5_0.jpg"];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createViewModel];
    });
}

-(void)createViewModel {
    NSArray *urls = @[@"https://www.jobtestprep.com/media/26727/xengineering-psychometric-tests.jpg.pagespeed.ic.vJ7Jp1MKTd.jpg", @"http://imaging.nikon.com/lineup/lens/zoom/normalzoom/af-s_dx_18-140mmf_35-56g_ed_vr/img/sample/sample1_l.jpg", @"http://myanmareiti.org/sites/default/files/sample-5_0.jpg", @"http://koncha.890m.com/wp-content/uploads/2016/06/2.jpg", @"http://imgsv.imaging.nikon.com/lineup/lens/zoom/normalzoom/af-s_nikkor28-300mmf_35-56gd_ed_vr/img/sample/sample4_l.jpg", @"https://www.nature.org/cs/groups/webcontent/@web/@giftplanning/documents/media/sample-cga-rates-splash-1.jpg", @"https://sneakernews.com/wp-content/uploads/2017/10/adidas-nmd-ts1-sample-3.jpg", @"http://imaging.nikon.com/lineup/lens/zoom/normalzoom/af-s_dx_18-140mmf_35-56g_ed_vr/img/sample/sample1_l.jpg", @"https://images.careers360.mobi/sites/default/files/content_pic_2016_dec/JEE-Advanced-Sample-Papers.jpg", @"https://usercontent2.hubstatic.com/12265895_f520.jpg", @"https://www.thewritingdesk.co.uk/twd/inksamples.jpg", @"https://www.jobtestprep.com/media/26727/xengineering-psychometric-tests.jpg.pagespeed.ic.vJ7Jp1MKTd.jpg", @"https://www.jobtestprep.com/media/26727/xengineering-psychometric-tests.jpg.pagespeed.ic.vJ7Jp1MKTd.jpg"];
    NSMutableArray<ImageCellViewModel *> *viewModels = [NSMutableArray new];
    for (NSString *url in urls) {
        ImageCellViewModel *viewModel = [[ImageCellViewModel alloc] initWithUrl:url imageHandler:self.imageHandler];
        [viewModels addObject: viewModel];
    }
    self.items = [viewModels copy];
    [self.collectionView reloadData];
}

-(void)setupConstraints {
    [self.collectionView edgesToView: self.view];
}

-(NestEgg *)imageHandler {
    if (! _imageHandler) {
        HttpClient *httpClient = [HttpClient new];
        NestEggDefaultCache *cache = [[NestEggDefaultCache alloc] initWithFolder: @"image-cache" timeoutInterval: 5];
        _imageHandler = [[NestEgg alloc] initWithHttpClient:httpClient cache:cache];
    }
    return _imageHandler;
}

-(UICollectionView *)collectionView {
    if (! _collectionView) {
        UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
    }
    return _collectionView;
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
        NSLog(@"Finished 1");
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
        NSLog(@"Finished 2");
        if (error) {
            strongSelf.label.text = @"Error";
        } else {
            strongSelf.label.text = @"Done";
        }
    }];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ImageCell *cell = (ImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSLog(@"Set view Model: %@", [self.items[indexPath.row] url]);
    cell.viewModel = self.items[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *imageCell = (ImageCell *)cell;
    [imageCell prepareForDisplay];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width, 100);
}


@end
