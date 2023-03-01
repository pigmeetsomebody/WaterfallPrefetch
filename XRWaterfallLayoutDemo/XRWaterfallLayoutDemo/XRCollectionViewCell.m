//
//  XRCollectionViewCell.m
//
//  Created by yanyuzhu on 2023/2/28.
//  Copyright © 2023 XR. All rights reserved.
//

#import "XRCollectionViewCell.h"
#import <UIImageView+WebCache.h>
@interface XRCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation XRCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    [self addGradientLayer];
    [self startAnimation];
    
    
}
- (void)layoutSubviews {
    self.gradientLayer.frame = self.bounds;

}

- (void)addGradientLayer {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    layer.startPoint = CGPointMake(0.0 , 1.0);
    layer.endPoint = CGPointMake(1.0, 1.0);
    UIColor *color0 = [UIColor colorWithWhite:0.85 alpha:1.0];
    UIColor *color1 = [UIColor colorWithWhite:0.95 alpha:1.0];
    layer.colors = @[(__bridge id)color0.CGColor, (__bridge id)color1.CGColor, (__bridge id)color0.CGColor];
    layer.locations = @[@0.0, @0.5, @1.0];
    self.gradientLayer = layer;
    [self.contentView.layer insertSublayer:layer atIndex:0];
}

- (void)startAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = @[@-1.0, @-0.5, @0.0];
    animation.toValue = @[@1.0, @1.5, @2.0];
    animation.repeatCount = HUGE_VALF;
    animation.duration = 0.9;
    animation.removedOnCompletion = NO;
    [self.gradientLayer addAnimation:animation forKey:animation.keyPath];
}

- (void)setImageURL:(NSURL *)imageURL {

    _imageURL = imageURL;
    [self.imageView sd_setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
}
@end
