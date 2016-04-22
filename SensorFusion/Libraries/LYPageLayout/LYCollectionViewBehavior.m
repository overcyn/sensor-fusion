#import "LYCollectionViewBehavior.h"

@implementation LYCollectionViewLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    LYCollectionViewLayoutAttributes *copy = [super copyWithZone:zone];
    [copy setOffset:[self offset]];
    return copy;
}

@end

@implementation LYCollectionViewContext
@end
