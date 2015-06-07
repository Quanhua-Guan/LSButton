//
//  LSButton.m
//  LSButton
//
//  Created by Yang on 2015/01/16.
//  Copyright (c) 2015年 Yang. All rights reserved.
//

#import "LSButton.h"
#import <CoreText/CoreText.h>
#import "UIImage+Tint.h"

static void getPoints(void* info, const CGPathElement* element)
{
    NSMutableArray* points = (__bridge NSMutableArray*) info;
    
    int nPoints;
    switch (element->type)
    {
        case kCGPathElementMoveToPoint:
            nPoints = 1;
            break;
        case kCGPathElementAddLineToPoint:
            nPoints = 1;
            break;
        case kCGPathElementAddQuadCurveToPoint:
            nPoints = 2;
            break;
        case kCGPathElementAddCurveToPoint:
            nPoints = 3;
            break;
        case kCGPathElementCloseSubpath:
            nPoints = 0;
            break;
        default:
            return;
    }
    NSMutableArray *pointInfoArrray = @[@(element->type), @[].mutableCopy].mutableCopy;
    NSMutableArray *pointsArray = pointInfoArrray[1];
    for (int i = 0; i < nPoints; i++) {
        [pointsArray addObject:[NSValue valueWithCGPoint:element->points[i]]];
    }
    [points addObject:pointInfoArrray];
}

@implementation LSButton {
    UIColor *realBGColor;
    UIImage *currentShadowImage;
}

+(LSButton *)buttonWithFrame:(CGRect)frame icon:(UIImage*)icon buttonColor:(UIColor *)buttonColor titleShadowColor:(UIColor *)titleShadowColor tintColor:(UIColor*)tintColor radius:(CGFloat)radius titleShadowAngel:(CGFloat)titleShadowAngel target:(id)tar action:(SEL)sel
{
    LSButton *button = [LSButton new];
    button.frame = frame;
    button.backgroundColor = buttonColor;
    [button setTitleShadowColor:titleShadowColor forState:UIControlStateNormal];
    button.tintColor = tintColor;
    button.layer.cornerRadius = radius;
    button.titleShadowAngel = titleShadowAngel;
    [button setImage:icon forState:UIControlStateNormal];
    [button addTarget:tar action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self setup];
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setup
{
    if (!self.titleShadowLength) {
        _titleShadowLength = 100;
    }
    if (!self.titleShadowAngel) self.titleShadowAngel = 45;
    
    self.layer.masksToBounds = YES;
}

#pragma mark - Getters

- (UIColor *)backgroundColor {
    return realBGColor;
}

#pragma mark - Setters

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    super.backgroundColor = [UIColor clearColor];
    realBGColor = backgroundColor;
    [self setNeedsDisplay];
}

- (void)setTitleShadowAngel:(CGFloat)titleShadowAngel {
    _titleShadowAngel = titleShadowAngel;
    [self setNeedsDisplay];
}

- (void)setTitleShadowLength:(CGFloat)titleShadowLength {
    _titleShadowLength = titleShadowLength;
    [self setNeedsDisplay];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    [self setNeedsDisplay];
}

- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleShadowColor:color forState:state];
    currentShadowImage = nil;
    currentShadowImage = [self.currentImage imageWithTintColor:self.currentTitleShadowColor];
    [self setNeedsDisplay];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
    currentShadowImage = nil;
    currentShadowImage = [self.currentImage imageWithTintColor:self.currentTitleShadowColor];
    [self setNeedsDisplay];
}

- (void)setHideTitleImageShadow:(BOOL)hideTitleImageShadow {
    _hideTitleImageShadow = hideTitleImageShadow;
    [self setNeedsDisplay];
}

- (void)setHideTitleStringShadow:(BOOL)hideTitleStringShadow {
    _hideTitleStringShadow = hideTitleStringShadow;
    [self setNeedsDisplay];
}

#pragma mark - Others

-(void)layoutSubviews
{
    [super layoutSubviews];
    //Set image always tint
    if (self.currentImage) {
        if (self.currentImage) [self setImage:[self.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    //
    if (!self.currentTitleShadowColor) {
        [self setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    // background color
    [realBGColor set];
    UIBezierPath *buttonBezierPath = [UIBezierPath bezierPathWithRect:rect];
    [buttonBezierPath fill];
    
    CGFloat radian = _titleShadowAngel / 180 * M_PI;
    CGFloat xCos = cos(radian);
    CGFloat ySin = sin(radian);
    
    // Title Image Shadow -> UIiButton.currentImage
    if (!_hideTitleImageShadow && self.currentImage)
    {
        // Color
        [self.currentTitleShadowColor set];
        // Start point
        CGPoint point = self.imageView.frame.origin;
        // Offset
        point.x += _titleShadowOffsetX;
        point.y -= _titleShadowOffsetY;
        // temp length
        CGFloat length = 1;
        // get shadow image
        CGContextSaveGState(ctx);
        if (currentShadowImage == nil) {
            currentShadowImage = [self.currentImage imageWithTintColor:self.currentTitleShadowColor];
        }
        UIImage *shadowImage = currentShadowImage;
        CGContextRestoreGState(ctx);
        // Drawing
        while (length < _titleShadowLength)
        {
            CGFloat x = point.x + length * xCos;
            CGFloat y = point.y + length * ySin;
            CGPoint drawPoint = CGPointMake(x, y);
            [shadowImage drawAtPoint:drawPoint];
            length += 0.25;
        }
    }
    
    // Title String Shadow -> UIButton.currentTitle
    if (self.currentTitle || self.currentAttributedTitle) {
        NSAttributedString *titleString = self.currentAttributedTitle;
        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: self.titleLabel.font};
        if (titleString == nil) {
            titleString = [[NSAttributedString alloc] initWithString:self.currentTitle attributes:attributes];
        }
        
        NSString *tokenString = @"\u2026";
        CTLineRef titleStringLine = CTLineCreateWithAttributedString((CFAttributedStringRef)titleString);
        CTLineTruncationType truncationType = kCTLineTruncationEnd;
        switch (self.titleLabel.lineBreakMode) {
            case NSLineBreakByWordWrapping:
            case NSLineBreakByCharWrapping:
            case NSLineBreakByClipping:
                tokenString = @"";
                break;
            case  NSLineBreakByTruncatingTail:
                truncationType = kCTLineTruncationEnd;
                break;
            case  NSLineBreakByTruncatingHead:
                truncationType = kCTLineTruncationStart;
                break;
            case  NSLineBreakByTruncatingMiddle:
                truncationType = kCTLineTruncationMiddle;
                break;
            default:
                break;
        }
        NSAttributedString *attributedTokenString = [[NSAttributedString alloc] initWithString:tokenString attributes:attributes];
        CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedTokenString);
        CTLineRef titleStringTruncatedLine = CTLineCreateTruncatedLine(titleStringLine, self.titleLabel.bounds.size.width, truncationType, truncationToken);
        if (titleStringTruncatedLine == nil) {
            titleStringTruncatedLine = truncationToken;
        }
        CFArrayRef runArray = CTLineGetGlyphRuns(titleStringTruncatedLine);
        
        ////////get the cgpath of attributed title////////
        // for each RUN
        CGMutablePathRef lettersPath = CGPathCreateMutable();
        for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
        {
            // Get FONT for this run
            CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
            CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
            
            // for each GLYPH in run
            for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
            {
                // get Glyph & Glyph-data
                CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
                CGGlyph glyph;
                CGPoint position;
                CTRunGetGlyphs(run, thisGlyphRange, &glyph);
                CTRunGetPositions(run, thisGlyphRange, &position);
                
                // Get PATH of outline
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(lettersPath, &t, letter);
                CGPathRelease(letter);
            }
        }
        CGPathCloseSubpath(lettersPath);
        CFRelease(titleStringTruncatedLine);
        /////////End of "get the cgpath of attributed title"////////
        
        CGRect stringRect = CGPathGetPathBoundingBox(lettersPath);
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, self.titleLabel.center.x - (stringRect.size.width) / 2.0, self.titleLabel.center.y + stringRect.size.height / 2.0f);
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        CGMutablePathRef stringPath = CGPathCreateMutableCopyByTransformingPath(lettersPath, &transform);
        transform = CGAffineTransformTranslate(transform, _titleShadowOffsetX, -_titleShadowOffsetY);
        CGMutablePathRef stringPathForShadow = CGPathCreateMutableCopyByTransformingPath(lettersPath, &transform);
        CFRelease(lettersPath);
        
        NSMutableArray *points = [NSMutableArray array];
        CGPathApply(stringPathForShadow, (void *)(points), getPoints);
        CFRelease(stringPathForShadow);
        
        if (!_hideTitleStringShadow) {
            [self.currentTitleShadowColor set];
            CGPoint currentPoint;
            for (NSArray *pointInfo in points) {
                NSInteger type = ((NSNumber *)pointInfo[0]).integerValue;
                NSArray *allPoints = pointInfo[1];
                switch (type)
                {
                    case kCGPathElementMoveToPoint:// 1 point
                    {
                        CGPoint point = ((NSValue *)allPoints[0]).CGPointValue;
                        currentPoint = point;
                    }
                        break;
                    case kCGPathElementAddLineToPoint:// 1 point
                    {
                        CGPoint startPoint = currentPoint;
                        CGPoint startPoint_ = CGPointMake(startPoint.x + _titleShadowLength * xCos, startPoint.y + _titleShadowLength * ySin);
                        CGPoint endPoint = ((NSValue *)allPoints[0]).CGPointValue;
                        CGPoint endPoint_ = CGPointMake(endPoint.x + _titleShadowLength * xCos, endPoint.y + _titleShadowLength * ySin);
                        
                        CGMutablePathRef stringSubpath = CGPathCreateMutable();
                        CGPathMoveToPoint(stringSubpath, NULL, startPoint.x, startPoint.y);
                        CGPathAddLineToPoint(stringSubpath, NULL, startPoint_.x, startPoint_.y);
                        CGPathAddLineToPoint(stringSubpath, NULL, endPoint_.x, endPoint_.y);
                        CGPathAddLineToPoint(stringSubpath, NULL, endPoint.x, endPoint.y);
                        CGPathCloseSubpath(stringSubpath);
                        CGContextAddPath(ctx, stringSubpath);
                        CGContextFillPath(ctx);
                        
                        CFRelease(stringSubpath);
                        currentPoint = endPoint;
                    }
                        break;
                    case kCGPathElementAddQuadCurveToPoint:// 2 points
                    {
                        CGPoint currentPoint_ = CGPointMake(currentPoint.x + _titleShadowLength * xCos, currentPoint.y + _titleShadowLength * ySin);
                        CGPoint controlPoint0 = ((NSValue *)allPoints[0]).CGPointValue;
                        CGPoint controlPoint0_ = CGPointMake(controlPoint0.x + _titleShadowLength * xCos, controlPoint0.y + _titleShadowLength * ySin);
                        CGPoint quadCurveEndPoint = ((NSValue *)allPoints[1]).CGPointValue;
                        CGPoint quadCurveEndPoint_ = CGPointMake(quadCurveEndPoint.x + _titleShadowLength * xCos, quadCurveEndPoint.y + _titleShadowLength * ySin);
                        
                        CGMutablePathRef stringSubpath = CGPathCreateMutable();
                        CGPathMoveToPoint(stringSubpath, NULL, currentPoint.x, currentPoint.y);
                        CGPathAddQuadCurveToPoint(stringSubpath, NULL, controlPoint0.x, controlPoint0.y, quadCurveEndPoint.x, quadCurveEndPoint.y);
                        CGPathAddLineToPoint(stringSubpath, NULL, quadCurveEndPoint_.x, quadCurveEndPoint_.y);
                        CGPathAddQuadCurveToPoint(stringSubpath, NULL, controlPoint0_.x, controlPoint0_.y, currentPoint_.x, currentPoint_.y);
                        CGPathCloseSubpath(stringSubpath);
                        CGContextAddPath(ctx, stringSubpath);
                        CGContextFillPath(ctx);
                        
                        CFRelease(stringSubpath);
                        currentPoint = quadCurveEndPoint;
                    }
                        break;
                    case kCGPathElementAddCurveToPoint:// 3 points
                    {
                        CGPoint currentPoint_ = CGPointMake(currentPoint.x + _titleShadowLength * xCos, currentPoint.y + _titleShadowLength * ySin);
                        CGPoint controlPoint0 = ((NSValue *)allPoints[0]).CGPointValue;
                        CGPoint controlPoint0_ = CGPointMake(controlPoint0.x + _titleShadowLength * xCos, controlPoint0.y + _titleShadowLength * ySin);
                        CGPoint controlPoint1 = ((NSValue *)allPoints[1]).CGPointValue;
                        CGPoint controlPoint1_ = CGPointMake(controlPoint1.x + _titleShadowLength * xCos, controlPoint1.y + _titleShadowLength * ySin);
                        CGPoint curveEndPoint = ((NSValue *)allPoints[2]).CGPointValue;
                        CGPoint curveEndPoint_ = CGPointMake(curveEndPoint.x + _titleShadowLength * xCos, curveEndPoint.y + _titleShadowLength * ySin);
                        
                        CGMutablePathRef stringSubpath = CGPathCreateMutable();
                        CGPathMoveToPoint(stringSubpath, NULL, currentPoint.x, currentPoint.y);
                        CGPathAddCurveToPoint(stringSubpath, NULL, controlPoint0.x, controlPoint0.y, controlPoint1.x, controlPoint1.y, curveEndPoint.x, curveEndPoint.y);
                        CGPathAddLineToPoint(stringSubpath, NULL, curveEndPoint_.x, curveEndPoint_.y);
                        CGPathAddCurveToPoint(stringSubpath, NULL, controlPoint1_.x, controlPoint1_.y, controlPoint0_.x, controlPoint0_.y, currentPoint_.x, currentPoint_.y);
                        CGPathCloseSubpath(stringSubpath);
                        CGContextAddPath(ctx, stringSubpath);
                        CGContextFillPath(ctx);
                        
                        CFRelease(stringSubpath);
                        currentPoint = curveEndPoint;
                    }
                        break;
                    case kCGPathElementCloseSubpath:// 0 point
                    {
                        // do nothing
                    }
                        break;
                    default:
                        break;
                }// end of switch
            }// end of for
        }// end of if
        
        // draw the title
        [self.currentTitleColor set];
        [[UIBezierPath bezierPathWithCGPath:stringPath] fill];
        self.titleLabel.alpha = 0.0f;
        CFRelease(stringPath);
    }
    [super drawRect:rect];
}

@end
