//
//  ImageAPIService.h
//  XRWaterfallLayoutDemo
//
//  Created by yanyuzhu on 2023/2/28.
//  Copyright © 2023 XR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XRImage.h"

typedef void(^DidFetchImages)( NSArray<XRImage *> * _Nullable imageList,  NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface ImageAPIService : NSObject
+ (void)fetchImagesWithPage:(NSUInteger)page pageSize:(NSUInteger)offset  completionBlock:(DidFetchImages)completion;
@end

NS_ASSUME_NONNULL_END
