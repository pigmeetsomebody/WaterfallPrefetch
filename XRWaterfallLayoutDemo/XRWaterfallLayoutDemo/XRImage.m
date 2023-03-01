//
//  XRImage.m
//  XRWaterfallLayoutDemo
//
//  Created by yanyuzhu on 2023/2/28.
//  Copyright © 2023 XR. All rights reserved.
//

#import "XRImage.h"

@implementation XRImage
+ (instancetype)imageWithImageDic:(NSDictionary *)imageDic {
    XRImage *image = [[XRImage alloc] init];
    NSString *urlString = [imageDic[@"src"] objectForKey:@"medium"];
    if (!urlString.length) {
        urlString = imageDic[@"url"];
    }
    image.imageURL = [NSURL URLWithString:urlString];
    image.imageW = [imageDic[@"width"] floatValue];
    image.imageH = [imageDic[@"height"] floatValue];
    return image;
}
@end
