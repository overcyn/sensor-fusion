#import "LYListSection.h"

@implementation LYListSection

#pragma mark - LYSection

@synthesize delegate;

- (void)configureCell:(LYListCell *)cell {
    cell.title = self.title;
    cell.detailTitle = self.detailTitle;
    cell.userInteractionEnabled = self.action != nil;
}

- (Class)cellClass {
    return [LYListCell class];
}

- (CGSize)sizeThatFits:(CGSize)size withCell:(LYListCell *)sizingCell {
    [self configureCell:sizingCell];
    return [sizingCell sizeThatFits:size];
}

- (BOOL)updateWithSection:(LYListSection *)item {
    if ([self.title isEqual:item.title] && [self.detailTitle isEqual:item.detailTitle]) {
        self.action = item.action;
        return YES;
    }
    return NO;
}

- (void)select {
    if (self.action) {
        self.action();
    }
}

@end


#define H_PADDING                   10
#define TITLE_DETAIL_PADDING        40

@interface LYListCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *separator;
@end

@implementation LYListCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.numberOfLines = 1;
        [self addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.font = [UIFont systemFontOfSize:16];
        self.detailLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.detailLabel];
        
        self.separator = [[UIView alloc] init];
        self.separator.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        [self addSubview:self.separator];
        
        [self reloadColor];
    }
    return self;
}

#pragma mark - Public

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)value {
    self.titleLabel.text = value;
    [self setNeedsLayout];
}

- (NSString *)detailTitle {
    return self.detailLabel.text;
}

- (void)setDetailTitle:(NSString *)value {
    self.detailLabel.text = value;
    [self setNeedsLayout];
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    CGFloat x = CGRectGetMinX(b) + H_PADDING;
    CGFloat maxX = CGRectGetMaxX(b) - H_PADDING;
    CGFloat maxWidth = CGRectGetWidth(b) - (H_PADDING * 2);
    {
        [self.titleLabel sizeToFit];
        CGRect f = self.titleLabel.frame;
        f.size.width = MIN(f.size.width, maxX - x);
        f.size.height = MAX([self.titleLabel.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.titleLabel.font} context:nil].size.height, CGRectGetHeight(b));
        f.origin.x = x;
        f.origin.y = roundf(b.origin.y + (b.size.height - f.size.height)/2);
        self.titleLabel.frame = f;
        x = CGRectGetMaxX(f) + H_PADDING;
    }
    {
        CGRect f = self.detailLabel.frame;
        f.size.width = maxX - x;
        CGFloat measuredHeight = [self.detailLabel.text boundingRectWithSize:CGSizeMake(maxWidth - TITLE_DETAIL_PADDING, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.detailLabel.font} context:nil].size.height * 2;
        f.size.height = MAX(measuredHeight, CGRectGetHeight(b));
        f.origin.x = CGRectGetMaxX(self.titleLabel.frame);
        f.origin.y = roundf(b.origin.y + (b.size.height - f.size.height)/2);
        self.detailLabel.frame = f;
    }
    {
        CGRect f;
        f.size.height = 1 / [[UIScreen mainScreen] scale];
        f.size.width = CGRectGetMaxX(b) - H_PADDING;
        f.origin.x = H_PADDING + b.origin.x;
        f.origin.y = b.origin.y + b.size.height - f.size.height;
        [self.separator setFrame:f];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self reloadColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self reloadColor];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGRect titleRect = [self.title boundingRectWithSize:CGSizeMake(size.width - 20.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    // use the remaining space. 60.0f is the preferred padding between detail & title (40) + the padding to title (20)
    CGRect detailTitleRect = [self.detailTitle boundingRectWithSize:CGSizeMake(size.width - titleRect.size.width - 60.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    
    CGFloat tallestLabel = MAX(CGRectGetHeight(titleRect), CGRectGetHeight(detailTitleRect)) * 2;
    
    tallestLabel += 16.0; // Add some vertical padding so we dont sit against the edges of the cell
    return CGSizeMake(size.width, MAX(50, tallestLabel));
}

#pragma mark - Internal

- (void)reloadColor {
    if (self.selected || self.highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
