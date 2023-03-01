//
//  ImageAPIService.m
//  XRWaterfallLayoutDemo
//
//  Created by yanyuzhu on 2023/2/28.
//  Copyright © 2023 XR. All rights reserved.
//

#import "ImageAPIService.h"


@implementation ImageAPIService

+ (void)fetchImagesWithPage:(NSUInteger)page pageSize:(NSUInteger)offset  completionBlock:(DidFetchImages)completion {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:@"https:\/\/api.pexels.com\/v1\/curated"] resolvingAgainstBaseURL:NO];
    NSURLQueryItem *pageItem = [[NSURLQueryItem alloc] initWithName:@"page" value:[NSString stringWithFormat:@"%lu", (unsigned long)page]];
    NSURLQueryItem *pageSizeItem = [[NSURLQueryItem alloc] initWithName:@"per_page" value:[NSString stringWithFormat:@"%lu", (unsigned long)offset]];
    [components setQueryItems:@[pageItem, pageSizeItem]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"3kqXTaxlM9GR8Ha9uC6YfsFDNpXXcQjdTSOjfsm1gAhDrWr1GTa5GI7E" forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonError;
        if (data && !error) {
           NSDictionary *imgListDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            NSArray *imageList = imgListDict[@"photos"];
            NSMutableArray<XRImage *> *images = [NSMutableArray array];
            [imageList enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull imgDict, NSUInteger idx, BOOL * _Nonnull stop) {
                XRImage *img = [XRImage imageWithImageDic:imgDict];
                [images addObject:img];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([images copy], nil);
            });
            
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    [dataTask resume];
}

@end
