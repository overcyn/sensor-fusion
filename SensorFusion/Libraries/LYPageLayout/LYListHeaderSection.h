#import "LYPageLayout.h"

@interface LYListHeaderSection : NSObject <LYSection>
@property (nonatomic, strong) NSString *title;
@end


@interface LYListHeaderCell : UICollectionViewCell
@property (nonatomic, strong) NSString *title;
@end
