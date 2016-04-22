#import <UIKit/UIKit.h>
@protocol LYPageDelegate;

/**
 The @c LYPage protocol describes the content to display in the @c
 LYPageViewController.

 In order to customize the @c LYPageViewController you are suggested to
 implement the @c LYPage protocol, and return the desired properties for each
 given method. The page view controller can be forced to reload these values by
 calling `[LYPageDelegate pageDidUpdate:]`. Additionally appearance methods
 from the view controller will be forwarded to the page (@c pageWillAppear,
 etc).
 */
@protocol LYPage <NSObject>
@property (nonatomic, readonly) NSArray *sections;
@optional
@property (nonatomic, weak) id<LYPageDelegate> delegate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIView *titleView;
@property (nonatomic, readonly) NSArray *rightBarButtonItems;
@property (nonatomic, readonly) NSArray *leftBarButtonItems;
@property (nonatomic, readonly) UIRefreshControl *refreshControl;
@property (nonatomic, readonly) UIStatusBarStyle preferredStatusBarStyle;
@property (nonatomic, readonly) BOOL hidesBackButton;
@property (nonatomic, readonly) BOOL hidesNavigationBar;
@property (nonatomic, readonly) BOOL scrollEnabled;
- (void)pageWillAppear;
- (void)pageWillDisappear;
- (void)pageDidAppear;
- (void)pageDidDisappear;
@end

/**
 The interface the @c LYPageViewController exposes to the @c LYPage.
 */
@protocol LYPageDelegate <NSObject>

/**
 Trigger the @c LYPageViewController to refresh its contents (sections, bar
 items, etc) based on the @c LYPage.

 @param page The @c LYPage to update.
 */
- (void)pageDidUpdate:(id<LYPage>)page;

/**
 Parent view controller for the page.

 @param page The corresponding @c LYPage.

 @returns The parent view controller.
 */
- (UIViewController *)parentViewControllerForPage:(id<LYPage>)page;
@end
