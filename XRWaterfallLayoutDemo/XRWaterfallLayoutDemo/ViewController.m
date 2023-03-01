//
//  ViewController.m
//
//  Created by yanyuzhu on 2023/2/28.
//  Copyright © 2023 XR. All rights reserved.
//

#import "ViewController.h"
#import "XRCollectionViewCell.h"
#import "XRWaterfallLayout.h"
#import "XRImage.h"
#import "ImageAPIService.h"
#import "SDWebImageManager.h"
@interface ViewController ()<UICollectionViewDataSource, XRWaterfallLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UITableViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<XRImage *> *images;
@property (nonatomic, strong) ImageAPIService *service;
@property (nonatomic, assign) NSUInteger nextPage;
@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, strong) NSMutableDictionary *operationDict;
@property (nonatomic, strong) NSMutableOrderedSet<NSIndexPath *> *orderedSet;
@property (nonatomic, assign) NSInteger prefetchItemSize;
@property (nonatomic, copy) NSSet<NSIndexPath *> *workingSet;
@end

@implementation ViewController

- (NSMutableArray *)images {
    //从plist文件中取出字典数组，并封装成对象模型，存入模型数组中
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableDictionary *)operationDict {
    if (!_operationDict) {
        _operationDict = [NSMutableDictionary dictionary];
    }
    return _operationDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nextPage = 2;
    self.pageSize = 80;
    self.prefetchItemSize = 5;
    //创建瀑布流布局
    XRWaterfallLayout *waterfall = [XRWaterfallLayout waterFallLayoutWithColumnCount:2];
    
    //设置各属性的值
//    waterfall.rowSpacing = 10;
//    waterfall.columnSpacing = 10;
//    waterfall.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    //或者一次性设置
    [waterfall setColumnSpacing:10 rowSpacing:10 sectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    
    //设置代理，实现代理方法
    waterfall.delegate = self;
    /*
     //或者设置block
     [waterfall setItemHeightBlock:^CGFloat(CGFloat itemWidth, NSIndexPath *indexPath) {
        //根据图片的原始尺寸，及显示宽度，等比例缩放来计算显示高度
        XRImage *image = self.images[indexPath.item];
        return image.imageH / image.imageW * itemWidth;
    }];
     */
    //创建collectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:waterfall];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"XRCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    [ImageAPIService fetchImagesWithPage:self.nextPage pageSize:self.pageSize completionBlock:^(NSArray * _Nullable imageList, NSError * _Nullable error) {
        NSLog(@"%@", imageList);
        [self.images addObjectsFromArray:imageList];
        [self.collectionView reloadData];
    }];
    // 利用系统API做预取
//    self.collectionView.prefetchingEnabled = YES;
//    self.collectionView.prefetchDataSource = self;
}

- (void)click {
    [self.images removeAllObjects];
    [self.collectionView reloadData];
}


//根据item的宽度与indexPath计算每一个item的高度
- (CGFloat)waterfallLayout:(XRWaterfallLayout *)waterfallLayout itemHeightForWidth:(CGFloat)itemWidth atIndexPath:(NSIndexPath *)indexPath {
    //根据图片的原始尺寸，及显示宽度，等比例缩放来计算显示高度
    XRImage *image = self.images[indexPath.item];
    return image.imageH / image.imageW * itemWidth;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XRCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageURL = self.images[indexPath.item].imageURL;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.orderedSet addObject:indexPath];
    [self updateWorkRange];
    
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.orderedSet removeObject:indexPath];
    [self updateWorkRange];
}

- (void)updateWorkRange {
    NSIndexPath *firstVisibleIndex = [self.orderedSet firstObject];
    NSIndexPath *lastVisibleIndex = [self.orderedSet lastObject];
    NSInteger beginIndex = firstVisibleIndex.item - self.prefetchItemSize > 0 ? firstVisibleIndex.item - self.prefetchItemSize : 0;
    NSInteger endIndex = firstVisibleIndex.item + self.prefetchItemSize < self.images.count ? firstVisibleIndex.item + self.prefetchItemSize : self.images.count;
    NSMutableArray<NSIndexPath *> *prefetchIndexPaths = [NSMutableArray array];
    NSMutableSet *updatedWorkingSet = [NSMutableSet set];
    for (NSInteger i = beginIndex; i < endIndex; ++i) {
        NSIndexPath *indexPaths = [NSIndexPath indexPathForItem:i inSection:firstVisibleIndex.section];
        if (![self.workingSet containsObject:indexPaths]) {
            [prefetchIndexPaths addObject:indexPaths];
        }
        [updatedWorkingSet addObject:indexPaths];
    }
    NSMutableArray<NSIndexPath *> *cancelIndexPaths = [NSMutableArray array];
    [self.workingSet enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![updatedWorkingSet containsObject:obj]) {
            [cancelIndexPaths addObject:obj];
        }
    }];
    self.workingSet = updatedWorkingSet;
    [self collectionView:self.collectionView prefetchItemsAtIndexPaths:[prefetchIndexPaths copy]];
    [self collectionView:self.collectionView cancelPrefetchingForItemsAtIndexPaths:[prefetchIndexPaths copy]];
}

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *imageURL = self.images[indexPath.item].imageURL;
        id<SDWebImageOperation> operation = [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [self.operationDict removeObjectForKey:[imageURL absoluteString]];
        }];
        [self.operationDict setObject:operation forKey:[imageURL absoluteString]];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *imageURL = self.images[indexPath.item].imageURL;
        id<SDWebImageOperation> operation = [self.operationDict objectForKey:[imageURL absoluteString]];
        [operation cancel];
        [self.operationDict removeObjectForKey:[imageURL absoluteString]];
    }];
}

@end
