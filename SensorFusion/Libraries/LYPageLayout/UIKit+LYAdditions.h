#import <UIKit/UIKit.h>

BOOL LYEqualObjects(id a, id b);

@interface UIScrollView (LYAdditions)
@property (nonatomic) UIEdgeInsets LYScrollIndicatorInsets;
@end

@interface UICollectionView (LYAdditions)
- (void)LYDeselectAllItems;
@end

void UIKitLYAdditionsCategoriesInclude();