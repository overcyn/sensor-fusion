#import "LYCollectionViewCustomBehavior.h"
#import "LYCollectionViewLayout.h"
#import "LYSection.h"

#define BACKGROUND_Z    -1
#define DEFAULT_Z       0
#define CATCHES_Z       1
#define HEADER_Z        2
#define FIXED_Z         10000
#define FLOATING_Z      10001
#define FADE_HEIGHT     50

@implementation LYDefaultBehavior

- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize size = [(id)context.collectionView.delegate collectionView:context.collectionView layout:context.layout sizeForItemAtIndexPath:indexPath];

    LYCollectionViewLayoutAttributes *attributes = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(0, context.y, size.width, size.height);

    if (!self.padding) {
        context.y = CGRectGetMaxY(attributes.frame);
    }
    context.x = 0;
    return attributes;
}

- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    // no-op
}

@end

@implementation LYFadeBehavior

- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize size = [(id)context.collectionView.delegate collectionView:context.collectionView layout:context.layout sizeForItemAtIndexPath:indexPath];

    LYCollectionViewLayoutAttributes *attributes = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(0, context.y, size.width, size.height);

    context.y = CGRectGetMaxY(attributes.frame);
    context.x = 0;
    return attributes;
}

- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    UIEdgeInsets scrollInsets = context.collectionView.scrollIndicatorInsets;
    CGPoint contentOffset = context.collectionView.contentOffset;
    CGFloat fadeY = context.collectionView.frame.size.height - scrollInsets.top - scrollInsets.bottom - self.fadeDistance;

    CGFloat distanceFromTop = attributes.frame.origin.y - (contentOffset.y + scrollInsets.top);
    if (distanceFromTop < fadeY - FADE_HEIGHT) {
        attributes.hidden = YES;
    } else if (distanceFromTop < fadeY) {
        attributes.hidden = NO;
        attributes.alpha = 1 - (fadeY - distanceFromTop) / FADE_HEIGHT;
    } else {
        attributes.hidden = NO;
        attributes.alpha = 1;
    }
}

@end

@implementation LYFloatingBehavior

- (id)init {
    if ((self = [super init])) {
        self.rectEdge = UIRectEdgeTop | UIRectEdgeLeft;
    }
    return self;
}

- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize size = [(id)context.collectionView.delegate collectionView:context.collectionView layout:context.layout sizeForItemAtIndexPath:indexPath];

    CGRect f = CGRectMake(0, 0, size.width, size.height); // handle y position in updateAttributes:
    if ((self.rectEdge & UIRectEdgeLeft) == UIRectEdgeLeft) {
        f.origin.x = self.floatingOffset.x;
    } else if ((self.rectEdge & UIRectEdgeRight) == UIRectEdgeRight) {
        f.origin.x = context.collectionView.frame.size.width - self.floatingOffset.x - size.width;
    }

    LYCollectionViewLayoutAttributes *attributes = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = f;
    attributes.zIndex = FLOATING_Z;
    return attributes;
}

- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    UIEdgeInsets scrollInsets = context.collectionView.scrollIndicatorInsets;
    CGPoint contentOffset = context.collectionView.contentOffset;

    CGRect f = attributes.frame;
    if ((self.rectEdge & UIRectEdgeTop) == UIRectEdgeTop) {
        f.origin.y = contentOffset.y + scrollInsets.top + self.floatingOffset.y;
    } else if ((self.rectEdge & UIRectEdgeBottom) == UIRectEdgeBottom) {
        f.origin.y = contentOffset.y + context.collectionView.frame.size.height - scrollInsets.bottom - self.floatingOffset.y - f.size.height;
    }
    attributes.frame = f;
}

@end

@implementation LYBackgroundBehavior

- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize size = context.collectionView.frame.size;

    LYCollectionViewLayoutAttributes *attributes = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(0, 0, size.width, size.height);
    attributes.zIndex = BACKGROUND_Z;
    return attributes;
}

- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    CGPoint contentOffset = context.collectionView.contentOffset;

    CGRect f = attributes.frame;
    f.origin.y = contentOffset.y;
    attributes.frame = f;
}

@end

@implementation LYHeaderBehavior

- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize size = [(id)context.collectionView.delegate collectionView:context.collectionView layout:context.layout sizeForItemAtIndexPath:indexPath];

    LYCollectionViewLayoutAttributes *attributes = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(0, context.y, size.width, size.height);
    attributes.zIndex = HEADER_Z + section;
    attributes.offset = CGPointMake(0, context.y);

    context.y = CGRectGetMaxY(attributes.frame);
    context.x = 0;
    return attributes;
}

- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    UIEdgeInsets scrollInsets = context.collectionView.scrollIndicatorInsets;
    CGPoint contentOffset = context.collectionView.contentOffset;

    CGRect f = attributes.frame;
    if (attributes.offset.y > contentOffset.y + scrollInsets.top) {
        f.origin.y = attributes.offset.y;
    } else {
        f.origin.y = contentOffset.y + scrollInsets.top;
    }
    attributes.frame = f;
}

@end

@implementation LYFixedBehavior

- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize size = [(id)context.collectionView.delegate collectionView:context.collectionView layout:context.layout sizeForItemAtIndexPath:indexPath];

    LYCollectionViewLayoutAttributes *attributes = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(0, context.y, size.width, size.height);
    attributes.zIndex = FIXED_Z;

    UIEdgeInsets insets = context.scrollIndicatorInsets;
    insets.top += attributes.frame.size.height;

    context.y = CGRectGetMaxY(attributes.frame);
    context.x = 0;
    context.scrollIndicatorInsets = insets;
    return attributes;
}

- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    UIEdgeInsets contentInset = context.collectionView.contentInset;
    CGPoint contentOffset = context.collectionView.contentOffset;

    CGRect f = attributes.frame;
    f.origin.y = contentOffset.y + contentInset.top;
    attributes.frame = f;
}

@end

@implementation LYCatchesBehavior

- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize size = [(id)context.collectionView.delegate collectionView:context.collectionView layout:context.layout sizeForItemAtIndexPath:indexPath];

    LYCollectionViewLayoutAttributes *attributes = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(0, context.y, size.width, size.height);
    attributes.offset = CGPointMake(0, context.y);
    attributes.zIndex = CATCHES_Z;

    context.y = CGRectGetMaxY(attributes.frame);
    context.x = 0;
    return attributes;
}

- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    UIEdgeInsets scrollInsets = context.collectionView.scrollIndicatorInsets;
    CGPoint contentOffset = context.collectionView.contentOffset;

    CGRect f = attributes.frame;
    if (attributes.offset.y < contentOffset.y + scrollInsets.top) {
        f.origin.y = attributes.offset.y;
    } else {
        f.origin.y = contentOffset.y + scrollInsets.top;
        CGSize size = [(id)context.collectionView.delegate collectionView:context.collectionView layout:context.layout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        f.size.height = size.height + (-(contentOffset.y + scrollInsets.top) /** 0.75*/);
    }
    attributes.frame = f;
}

@end

@implementation LYGridBehavior

- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize size = [(id)context.collectionView.delegate collectionView:context.collectionView layout:context.layout sizeForItemAtIndexPath:indexPath];

    CGRect f;
    f.size = size;
    f.origin.y = context.y;
    f.origin.x = context.x;
    if (![context.previousBehavior isKindOfClass:[LYGridBehavior class]]) {
        f.origin.y += self.insets.top;
        f.origin.x += self.insets.left;
    } else {
        f.origin.y -= self.insets.bottom;
        if (f.origin.x + size.width <= context.collectionView.frame.size.width - self.insets.right) {
            f.origin.y -= f.size.height;
            f.origin.x = context.x;
        } else {
            f.origin.y += self.lineSpacing;
            f.origin.x = self.insets.left;
        }
    }

    LYCollectionViewLayoutAttributes *attributes = [LYCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = f;

    context.y = CGRectGetMaxY(attributes.frame) + self.insets.bottom;
    context.x = CGRectGetMaxX(attributes.frame) + self.interitemSpacing;
    return attributes;
}

- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context {
    // no-op
}

@end
