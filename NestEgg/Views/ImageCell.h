//
//  ImageCell.h
//  NestEgg
//
//  Created by Ido Mizrachi on 2/10/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageCellViewModel;

@interface ImageCell : UICollectionViewCell

@property (nonatomic, strong) ImageCellViewModel *viewModel;

-(void)prepareForDisplay;

@end
