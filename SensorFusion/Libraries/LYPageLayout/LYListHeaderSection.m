#import "LYListHeaderSection.h"

@interface LYListHeaderSection ()
@property (nonatomic, strong) LYHeaderBehavior *behavior;
@end

@implementation LYListHeaderSection

#pragma LYSection

@synthesize delegate;

- (void)setup {
    self.behavior = [[LYHeaderBehavior alloc] init];
}

- (void)configureCell:(LYListHeaderCell *)cell {
    cell.title = self.title;
}

- (Class)cellClass {
    return [LYListHeaderCell class];
}

- (CGSize)sizeThatFits:(CGSize)size withCell:(LYListHeaderCell *)sizingCell {
    return [sizingCell sizeThatFits:size];
}

- (BOOL)updateWithSection:(LYListHeaderSection *)item {
    return [self.title isEqual:item.title];
}

@end


#define H_PADDING               10

@interface LYListHeaderCell ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation LYListHeaderCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.label = [[UILabel alloc] init];
        self.label.font = [UIFont boldSystemFontOfSize:13];
        self.label.textColor = [UIColor whiteColor];
        [self addSubview:self.label];
        
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    }
    return self;
}

#pragma mark - Public

- (NSString *)title {
    return self.label.text;
}

- (void)setTitle:(NSString *)value {
    self.label.text = [value uppercaseStringWithLocale:[NSLocale currentLocale]];
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    {
        [self.label sizeToFit];
        CGRect f = [self.label frame];
        f.origin.x = b.origin.x + H_PADDING;
        f.origin.y = roundf(b.origin.y + (b.size.height - f.size.height)/2);
        f.size.width = b.size.width - H_PADDING * 2;
        [self.label setFrame:f];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, 27);
}

@end
