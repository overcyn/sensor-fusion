#import <UIKit/UIKit.h>
@class LYCollectionViewContext;
@class LYCollectionViewLayout;

/**
 A @c UICollectionViewLayoutAttributes subclass with additional properties for
 behaviors to persist layout information.
 */
@interface LYCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic) CGPoint offset;
@end

/**
 Objects can conform to @c LYCollectionViewBehavior to calculate and return
 custom layout attributes for a section (on launch and on every scroll change).
 */
@protocol LYCollectionViewBehavior <NSObject>
- (LYCollectionViewLayoutAttributes *)getAttributesForSection:(NSInteger)section context:(LYCollectionViewContext *)context;
- (void)updateAttributes:(LYCollectionViewLayoutAttributes *)attributes forSection:(NSInteger)section context:(LYCollectionViewContext *)context;
@end

/**
 An object sent to the @c LYCollectionViewBehavior containing contextual
 information and current layout status.

 As @c LYCollectionViewLayout iterates over all the section's behaviors and
 fetches layout attributes, each behavior can update the context object (e.g.
 increasing the current @c x, @c y) and these values will be seen by later
 behaviors.
 */
@interface LYCollectionViewContext : NSObject
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LYCollectionViewLayout *layout;
@property (nonatomic, strong) id<LYCollectionViewBehavior> previousBehavior;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) UIEdgeInsets scrollIndicatorInsets;
@end
