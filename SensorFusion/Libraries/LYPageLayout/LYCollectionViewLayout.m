#import "LYCollectionViewLayout.h"
#import "LYCollectionViewBehavior.h"
#import "LYCollectionViewCustomBehavior.h"
#import "UIKit+LYAdditions.h"

@implementation LYCollectionViewLayout {
    CGSize _sizeAtSetup;
    BOOL _valid;
    CGSize _contentSize;
    NSArray *_attributesArray;
    LYDefaultBehavior *_defaultBehavior;
}

+ (Class)layoutAttributesClass {
    return [LYCollectionViewLayoutAttributes class];
}

- (id)init {
    if ((self = [super init])) {
        _defaultBehavior = [[LYDefaultBehavior alloc] init];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    if (!CGSizeEqualToSize([[self collectionView] frame].size, _sizeAtSetup)) {
        _valid = NO;
    }
    if (!_valid) {
        [self _setup];
    }
    [self _updateAttributes];
}

- (CGSize)collectionViewContentSize {
    return _contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.collectionView.delegate == nil) { // Avoid crashes if LYPageViewController deallocates before the UICollectionView
        return @[];
    }
    NSMutableArray *attributesArray = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes *i in _attributesArray) {
        if (CGRectIntersectsRect(i.frame, rect)) {
            [attributesArray addObject:i];
        }
    }
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _attributesArray[indexPath.section];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
    [super invalidateLayoutWithContext:context];
    if (context.invalidateEverything || context.invalidateDataSourceCounts) {
        _valid = NO;
    }
}

#pragma mark - Internal

- (void)_setup {
    UICollectionView *view = self.collectionView;

    NSMutableArray *attributesArray = [NSMutableArray new];
    LYCollectionViewContext *context = [LYCollectionViewContext new];
    context.collectionView = view;
    context.layout = self;
    for (NSInteger i = 0; i < [view numberOfSections]; i++) {
        id<LYCollectionViewBehavior> behavior = [(id)view.delegate collectionView:view layout:self behaviorForSectionAtIndex:i] ?: _defaultBehavior;
        [attributesArray addObject:[behavior getAttributesForSection:i context:context]];
        context.previousBehavior = behavior;
    }

    view.LYScrollIndicatorInsets = context.scrollIndicatorInsets;

    // on iOS 7, UICollectionView doesn't display if the contentSize is 0. Work around by ensuring the contentSize is at least equal to the visible frame.
    _contentSize = CGSizeMake(view.frame.size.width, MAX(context.y, view.frame.size.height - view.scrollIndicatorInsets.top - view.scrollIndicatorInsets.bottom));
    _attributesArray = attributesArray;
    _sizeAtSetup = view.frame.size;
    _valid = YES;
}

- (void)_updateAttributes {
    UICollectionView *view = self.collectionView;

    LYCollectionViewContext *context = [LYCollectionViewContext new];
    context.collectionView = view;
    context.layout = self;
    for (NSInteger i = 0; i < [view numberOfSections]; i++) {
        id<LYCollectionViewBehavior> behavior = [(id)view.delegate collectionView:view layout:self behaviorForSectionAtIndex:i] ?: _defaultBehavior;
        [behavior updateAttributes:_attributesArray[i] forSection:i context:context];
        context.previousBehavior = behavior;
    }
}

@end
