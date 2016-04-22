#import <UIKit/UIKit.h>
@protocol LYCollectionViewBehavior;

/**
 A custom @c LYCollectionViewLayout subclass that performs the layout logic for
 @c LYPageViewController.
 */
@interface LYCollectionViewLayout : UICollectionViewLayout
@end

/**
 Additional delegate methods for @c UICollectionViewDelegate
 */
@protocol LYCollectionViewDelegateLayout <UICollectionViewDelegate>
- (id<LYCollectionViewBehavior>)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout behaviorForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end
