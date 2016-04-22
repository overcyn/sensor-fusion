#import <UIKit/UIKit.h>
@protocol LYPage;

/**
 A view controller which handles the management of a @c UICollectionView and its
 cells.

 Do not subclass @c LYPageViewController! Instead return a custom @c LYPage
 which details the content to be displayed.
 */
@interface LYPageViewController : UIViewController
@property (nonatomic, strong) id<LYPage> page;
@end
