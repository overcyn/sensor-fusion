#import "LYPageLayout.h"

@interface LYListSection : NSObject <LYSection>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detailTitle;
@property (nonatomic, copy) void (^action)(void);
@end


@interface LYListCell : UICollectionViewCell
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detailTitle;
@end
