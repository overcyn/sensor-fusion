#import <UIKit/UIKit.h>
#import "LYCollectionViewLayout.h"
@protocol LYSectionDelegate;

/**
 Describes the behavior of a single UICollectionViewCell (cellClass, size,
 scroll behavior, onSelect action, etc).

 Sections are returned by the @c LYPage which populate the @c
 LYPageViewController. Create a concrete implementation of LYSection in order to
 add a new custom cell class.
 */
@protocol LYSection <NSObject>
@property (nonatomic, weak) id<LYSectionDelegate> delegate;
@property (nonatomic, readonly) Class cellClass;
- (void)configureCell:(UICollectionViewCell *)cell;
- (CGSize)sizeThatFits:(CGSize)size withCell:(UICollectionViewCell *)sizingCell;
- (BOOL)updateWithSection:(id<LYSection>)section;
@optional
@property (nonatomic, readonly) id<LYCollectionViewBehavior> behavior;
- (void)setup;
- (void)select;
- (NSArray *)operations;
@end

/**
 Interface that the @c LYPageViewController exposes to the @c LYSection.
 */
@protocol LYSectionDelegate <NSObject>
- (UIViewController *)parentViewControllerForSection:(id<LYSection>)section;
- (UICollectionViewCell *)visibleCellForSection:(id<LYSection>)section;
- (void)reloadSection:(id<LYSection>)section;
@end
