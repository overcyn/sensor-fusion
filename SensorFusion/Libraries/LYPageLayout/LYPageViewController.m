#import "LYPageViewController.h"
#import "LYSection.h"
#import "LYPage.h"
#import "LYCollectionViewLayout.h"
#import "UIKit+LYAdditions.h"

@interface WLCollectionViewLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext
@end
@implementation WLCollectionViewLayoutInvalidationContext
- (BOOL)invalidateEverything {
    return YES;
}
@end

@interface LYPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, LYPageDelegate, LYSectionDelegate>
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableDictionary *sizingCells;
@property (nonatomic, strong) NSOperationQueue *opQueue;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation LYPageViewController

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle {
    if ((self = [super initWithNibName:name bundle:bundle])) {
        self.sections = [NSMutableArray new];
        self.opQueue = [[NSOperationQueue alloc] init];
        self.opQueue.maxConcurrentOperationCount = 5;
        self.opQueue.suspended = YES;
        self.sizingCells = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

#pragma mark - API

- (void)setPage:(id<LYPage>)page {
    _page = page;
    if ([_page respondsToSelector:@selector(setDelegate:)]) {
        _page.delegate = self;
    }
    [self pageDidUpdate:_page];
}

#pragma mark - UIViewController

- (void)loadView {
    LYCollectionViewLayout *layout = [LYCollectionViewLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.view = self.collectionView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView LYDeselectAllItems];
    if ([self.page respondsToSelector:@selector(pageWillAppear)]) {
        [self.page pageWillAppear];
    }
    if ([self.page respondsToSelector:@selector(hidesNavigationBar)] && self.page.hidesNavigationBar) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.page respondsToSelector:@selector(pageDidAppear)]) {
        [self.page pageDidAppear];
    }
    self.opQueue.suspended = NO;

    // KD: Hack to fix missing nav bar when cancelling out of swipe back gesture. Something to do with changing statusBar styles.
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.page respondsToSelector:@selector(hidesNavigationBar)] && self.page.hidesNavigationBar) {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        } else {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.page respondsToSelector:@selector(pageWillDisappear)]) {
        [self.page pageWillDisappear];
    }
    if ([self.page respondsToSelector:@selector(hidesNavigationBar)] && self.page.hidesNavigationBar && self.navigationController.topViewController != self) { // KD: WEIRD HACK
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self.page respondsToSelector:@selector(pageDidDisappear)]) {
        [self.page pageDidDisappear];
    }
    self.opQueue.suspended = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([self.page respondsToSelector:@selector(preferredStatusBarStyle)]) {
        return self.page.preferredStatusBarStyle;
    }
    return super.preferredStatusBarStyle;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [super didRotateFromInterfaceOrientation:orientation];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)index {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<LYSection> item = self.sections[indexPath.section];
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(item.cellClass) forIndexPath:indexPath];
    [item configureCell:cell];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id<LYSection> section = self.sections[indexPath.section];
    if ([section respondsToSelector:@selector(select)]) {
        [(id<LYSection>)section select];
    }
    // Deselect afterwards if we weren't pushed
    if (self.navigationController.topViewController == self) {
        [self.collectionView LYDeselectAllItems];
    }
}

#pragma mark - LYCollectionViewDelegateLayout

- (id<LYCollectionViewBehavior>)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout behaviorForSectionAtIndex:(NSInteger)index {
    id<LYSection> section = self.sections[index];
    return [section respondsToSelector:@selector(behavior)] ? section.behavior : nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = self.view.frame.size;
    size.height -= self.collectionView.scrollIndicatorInsets.top + self.collectionView.scrollIndicatorInsets.bottom;
    id<LYSection> item = self.sections[indexPath.section];
    NSString *string = NSStringFromClass(item.cellClass);
    UICollectionViewCell *sizingCell = self.sizingCells[string];
    return [item sizeThatFits:size withCell:sizingCell];
}

#pragma mark - LYPageDelegate

- (UIViewController *)parentViewControllerForPage:(id<LYPage>)page {
    return self;
}

- (void)pageDidUpdate:(id<LYPage>)page {
    [self view]; // Force the view to load

    if ([self.page respondsToSelector:@selector(title)]) {
        self.title = self.page.title;
    }
    if ([self.page respondsToSelector:@selector(rightBarButtonItems)]) {
        if (!NSEqualObjects(self.navigationItem.rightBarButtonItems, self.page.rightBarButtonItems)) {
            self.navigationItem.rightBarButtonItems = self.page.rightBarButtonItems;
        }
    }
    if ([self.page respondsToSelector:@selector(leftBarButtonItems)]) {
        if (!NSEqualObjects(self.navigationItem.leftBarButtonItems, self.page.leftBarButtonItems)) {
            self.navigationItem.leftBarButtonItems = self.page.leftBarButtonItems;
        }
    }
    if ([self.page respondsToSelector:@selector(titleView)]) {
        if (!NSEqualObjects(self.navigationItem.titleView, self.page.titleView)) {
            self.navigationItem.titleView = self.page.titleView;
        }
    }
    if ([self.page respondsToSelector:@selector(hidesBackButton)]) {
        self.navigationItem.hidesBackButton = self.page.hidesBackButton;
    }
    if ([self.page respondsToSelector:@selector(scrollEnabled)]) {
        self.collectionView.scrollEnabled = self.page.scrollEnabled;
    }
    if ([self.page respondsToSelector:@selector(refreshControl)]) {
        if (self.refreshControl != self.page.refreshControl) {
            [self.refreshControl removeFromSuperview];
            self.refreshControl = self.page.refreshControl;
            [self.collectionView insertSubview:self.refreshControl atIndex:0];
        }
    }
    [self reloadSections];
}

#pragma mark - LYSectionDelegate

- (UIViewController *)parentViewControllerForSection:(id<LYSection>)item {
    return self;
}

- (UICollectionViewCell *)visibleCellForSection:(id<LYSection>)item {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:[self.sections indexOfObject:item]];
    if ([self.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
        return [self.collectionView cellForItemAtIndexPath:indexPath];
    }
    return nil;
}

- (void)reloadSection:(id<LYSection>)item {
    NSInteger sectionIndex = [self.sections indexOfObject:item];
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:sectionIndex]]];
}

#pragma mark - Internal

- (void)reloadSections {
    [self view]; // Force the view to load

    // Diff arrays
    NSMutableIndexSet *newIndexes = [NSMutableIndexSet new];
    NSMutableArray *newItems = [self.page.sections mutableCopy];
    NSMutableArray *oldItems = self.sections;
    for (NSInteger i = 0; i < newItems.count; i++) {
        id<LYSection> newItem = newItems[i];
        Class newClass = newItem.class;
        id<LYSection> found = nil;
        NSInteger foundIndex = NSNotFound;
        for (NSInteger j = 0; j < oldItems.count; j++) {
            id<LYSection> oldItem = oldItems[j];
            if ([oldItem isMemberOfClass:newClass] && [oldItem updateWithSection:newItem]) {
                found = oldItem;
                foundIndex = j;
                break;
            }
        }
        if (found) {
            [newItems replaceObjectAtIndex:i withObject:found];
            [oldItems removeObjectAtIndex:foundIndex];
        } else {
            [newIndexes addIndex:i];
        }
    }
    // Cancel operations for removed sections
    for (id<LYSection> i in oldItems) {
        if ([i respondsToSelector:@selector(operations)]) {
            for (NSOperation *j in i.operations) {
                [j cancel];
            }
        }
    }
    // Initalize added sections
    self.sections = newItems;
    [newIndexes enumerateIndexesUsingBlock:^(NSUInteger i, BOOL *stop){
        id<LYSection> section = self.sections[i];
        section.delegate = self;
        if ([section respondsToSelector:@selector(setup)]) {
            [section setup];
        }
        if ([section respondsToSelector:@selector(operations)]) {
            for (NSOperation *j in section.operations) {
                [self.opQueue addOperation:j];
            }
        }
        NSString *string = NSStringFromClass(section.cellClass);
        if (!self.sizingCells[string]) {
            [self.collectionView registerClass:section.cellClass forCellWithReuseIdentifier:string];
            self.sizingCells[string] = [[section.cellClass alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        }
    }];

    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[WLCollectionViewLayoutInvalidationContext new]]; // iOS 7 does not invalidate everything on reloadData...
    [self.collectionView reloadData];
}

+ (void)includeCategories {
    // This will make sure all our category helpers are included in the final binary
    UIKitLYAdditionsCategoriesInclude();
}

@end
