//
//  ActressCodeController.m
//  JAVBus
//
//  Created by mgfjx on 2018/12/13.
//  Copyright © 2018 mgfjx. All rights reserved.
//

#import "ActressCodeController.h"
#import "HtmlToJsonManager.h"
#import "ActressCell.h"
#import "ActressModel.h"
#import "RxWebViewController.h"

@interface ActressCodeController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView ;

@property (nonatomic, strong) NSArray *actressArray ;

@property (nonatomic, assign) NSInteger page ;

@end

@implementation ActressCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    [self initCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCollectionView {
    
    CGFloat width = MainWidth;
    
    CGFloat offset = 4;
    CGFloat itemWidth = floorf((width - 5*offset)/3);
    CGFloat itemHeight = itemWidth + itemWidth*1/3;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = offset;
    layout.minimumInteritemSpacing = offset;
    layout.sectionInset = UIEdgeInsetsMake(offset, offset, offset, offset);
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collection.delegate = self;
    collection.dataSource = self;
    collection.backgroundColor = [UIColor whiteColor];
    //    [collection registerClass:[ActressCell class] forCellWithReuseIdentifier:NSStringFromClass([ActressCell class])];
    [collection registerNib:[UINib nibWithNibName:NSStringFromClass([ActressCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ActressCell class])];
    
    [self.view addSubview:collection];
    self.collectionView = collection;
    
    collection.canPullDown = YES;
    collection.canPullUp = YES;
    WeakSelf(weakSelf)
    collection.headerRefreshBlock = ^(UIScrollView *rfScrollView) {
        [weakSelf requestData:YES];
    };
    collection.footerRefreshBlock = ^(UIScrollView *rfScrollView) {
        [weakSelf requestData:NO];
    };
    
    [collection startHeaderRefreshing];
    
}

- (void)requestData:(BOOL)refresh {
    
    if (refresh) {
        self.page = 1;
    }else{
        self.page ++;
    }
    
    [HTMLTOJSONMANAGER parseActressDataByPage:self.page callback:^(NSArray *array) {
        if (refresh) {
            self.actressArray = array;
        }else{
            NSMutableArray *arr1 = [NSMutableArray arrayWithArray:self.actressArray];
            [arr1 addObjectsFromArray:array];
            self.actressArray = [arr1 copy];
        }
        [self.collectionView stopHeaderRefreshing];
        [self.collectionView stopFooterRefreshing];
        [self.collectionView reloadData];
    }];
    
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.actressArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ActressCell *cell = (ActressCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ActressCell class]) forIndexPath:indexPath];
    
    ActressModel *model = self.actressArray[indexPath.item];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholderImage:[UIImage imageNamed:@"actressHolder"]];
    cell.titleLabel.text = model.name;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ActressModel *model = self.actressArray[indexPath.item];
    
    RxWebViewController *vc = [[RxWebViewController alloc] initWithUrl:[NSURL URLWithString:model.link]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end