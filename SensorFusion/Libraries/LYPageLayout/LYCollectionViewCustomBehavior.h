#import "LYCollectionViewBehavior.h"

/**
 Behavior that tiles cells vertically.
 */
@interface LYDefaultBehavior : NSObject <LYCollectionViewBehavior>
// Disable extending content size
@property (nonatomic) BOOL padding;
@end

/**
 Behavior that gradually fades out cells a certain distance from the bottom.
 */
@interface LYFadeBehavior : NSObject <LYCollectionViewBehavior>
@property (nonatomic) CGFloat fadeDistance;
@end

/**
 Behavior that floats cells at an offset from a corner
 */
@interface LYFloatingBehavior : NSObject <LYCollectionViewBehavior>
@property (nonatomic) CGPoint floatingOffset;
@property (nonatomic) UIRectEdge rectEdge;
@end

/**
 Behavior that sizes cells to full screen and fixes to the background.
 */
@interface LYBackgroundBehavior : NSObject <LYCollectionViewBehavior>
@end

/**
 Behavior that acts like UITableViewSectionHeader.
 */
@interface LYHeaderBehavior : NSObject <LYCollectionViewBehavior>
@end

/**
 Behavior that permanently fixes cells to the top, and adjusts the scroll insets to compensate.
 */
@interface LYFixedBehavior : NSObject <LYCollectionViewBehavior>
@end

/**
 If cells would be below the navbar, pins them to top, otherwise scrolls normally.
 */
@interface LYCatchesBehavior : NSObject <LYCollectionViewBehavior>
@end

/**
 Behavior that tiles cells in a grid.
 */
@interface LYGridBehavior : NSObject <LYCollectionViewBehavior>
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat interitemSpacing;
@end
