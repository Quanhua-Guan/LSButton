//
//  LSButton.m
//  LSButton
//
//  Created by Yang on 2015/01/16.
//  Copyright (c) 2015年 Yang. All rights reserved.
//

#import "LSButton.h"
#import <CoreText/CoreText.h>

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


@implementation LSButton

+(LSButton *)buttonWithFrame:(CGRect)frame icon:(UIImage*)icon buttonColor:(UIColor *)buttonColor shadowColor:(UIColor *)shadowColor tintColor:(UIColor*)tintColor radius:(CGFloat)radius angel:(CGFloat)angel target:(id)tar action:(SEL)sel
{
    LSButton *button = [LSButton new];
    button.frame = frame;
    button.buttonColor = buttonColor;
    button.shadowColor = shadowColor;
    button.tintColor = tintColor;
    button.radius = radius;
    button.angel = angel;
    [button setImage:icon forState:UIControlStateNormal];
    [button addTarget:tar action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (id)initWithFrame:(CGRect)frame
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
    if (!self.buttonColor) self.buttonColor = [UIColor colorWithRed:0.400 green:0.800 blue:1.000 alpha:1.000];
    if (!self.shadowColor) self.shadowColor = [UIColor colorWithWhite:0.326 alpha:1.000];
    if (!self.angel) self.angel = 45;
    self.backgroundColor = [UIColor clearColor];
}

-(void)setRadius:(CGFloat)radius
{
    _radius = MIN(radius, self.frame.size.width / 2.0);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //Set image always tint
    if (self.currentImage) [self setImage:[self.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    [self.buttonColor setFill];
    UIBezierPath *p = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.radius];
    
    [p fill];
    [p addClip];
    
    [self.shadowColor setFill];
    
    CGFloat radian = _angel / 180 * M_PI;
    CGFloat x,y;
    if (fabs(sin(radian)) >= fabs(cos(radian)))
    {
        x = cos(radian) * ( 1 / fabs(sin(radian)));
        y = 1 * ( sin(radian) < 0 ? -1 : 1 );
    } else {
        x = 1 * ( cos(radian) < 0 ? -1 : 1 );
        y = sin(radian) * ( 1 / fabs(cos(radian)));
    }
    
    if (self.currentImage)
    {
        //Start point
        CGPoint point = self.imageView.frame.origin;
        point.x += _shadowXOffset;
        point.y -= _shadowYOffset;
        while (true)
        {
            [self.currentImage drawAtPoint:point];
            
            if (CGRectContainsPoint(rect, point) ||
                CGRectContainsPoint(rect,CGPointMake(point.x + self.currentImage.size.width, point.y + self.currentImage.size.height)) ||
                CGRectContainsPoint(rect,CGPointMake(point.x + self.currentImage.size.width, point.y)) ||
                CGRectContainsPoint(rect,CGPointMake(point.x , point.y + self.currentImage.size.height)))
            {
                point = CGPointMake(point.x + x, point.y + y);
            }
            else
            {
                break;
            }
        }
    } else {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.currentTitle attributes:@{NSForegroundColorAttributeName: self.shadowColor, NSFontAttributeName: self.titleLabel.font}];
        
        NSAttributedString *attrString = str;
        CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
        CFArrayRef runArray = CTLineGetGlyphRuns(line);
        
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
                {
                    CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                    CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                    CGPathAddPath(lettersPath, &t, letter);
                    CGPathRelease(letter);
                }
            }
        }
        CFRelease(line);
    
        ///////////////
        
        CGRect stringBoundingRect = [attrString boundingRectWithSize:rect.size
                                                             options:(NSStringDrawingUsesLineFragmentOrigin |  NSStringDrawingUsesFontLeading)
                                                             context:nil];// 宽度准确可用
        CGRect pathBoundingBox = CGPathGetBoundingBox(lettersPath);// 高度准确可用
        CGRect stringRect = CGRectMake(0, 0, ceil(stringBoundingRect.size.width), ceil(pathBoundingBox.size.height));
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, self.titleLabel.center.x - (stringRect.size.width) / 2.0, self.titleLabel.center.y + stringRect.size.height / 2.0f);
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        transform = CGAffineTransformTranslate(transform, _shadowXOffset, -_shadowYOffset);
        CGMutablePathRef stringPath = CGPathCreateMutableCopyByTransformingPath(lettersPath, &transform);
        CFRelease(lettersPath);
        
        CGContextAddPath(ctx, stringPath);
        CGContextFillPath(ctx);
        
        CGFloat l = MAX(rect.size.width, rect.size.height) * 4.0f;
        
        NSMutableArray *points = [NSMutableArray array];
        CGPathApply(stringPath, (void *)(points), getPoints);
        
        CFRelease(stringPath);
        
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
                    CGPoint point0 = currentPoint;
                    CGPoint point0_ = CGPointMake(point0.x + l * x, point0.y + l * y);
                    CGPoint point1 = ((NSValue *)allPoints[0]).CGPointValue;
                    CGPoint point1_ = CGPointMake(point1.x + l * x, point1.y + l * y);
                    
                    CGMutablePathRef stringSubpath = CGPathCreateMutable();
                    CGPathMoveToPoint(stringSubpath, NULL, point0.x, point0.y);
                    CGPathAddLineToPoint(stringSubpath, NULL, point0_.x, point0_.y);
                    CGPathAddLineToPoint(stringSubpath, NULL, point1_.x, point1_.y);
                    CGPathAddLineToPoint(stringSubpath, NULL, point1.x, point1.y);
                    CGPathCloseSubpath(stringSubpath);
                    CGContextAddPath(ctx, stringSubpath);
                    CGContextFillPath(ctx);
                    
                    CFRelease(stringSubpath);
                    
                    currentPoint = point1;
                }
                    break;
                case kCGPathElementAddQuadCurveToPoint:// 2 points
                {
                    
                    CGPoint currentPoint_ = CGPointMake(currentPoint.x + l * x, currentPoint.y + l * y);
                    CGPoint controlPoint0 = ((NSValue *)allPoints[0]).CGPointValue;
                    CGPoint controlPoint0_ = CGPointMake(controlPoint0.x + l * x, controlPoint0.y + l * y);
                    CGPoint quadCurveEndPoint = ((NSValue *)allPoints[1]).CGPointValue;
                    CGPoint quadCurveEndPoint_ = CGPointMake(quadCurveEndPoint.x + l * x, quadCurveEndPoint.y + l * y);
                    
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
                    CGPoint currentPoint_ = CGPointMake(currentPoint.x + l * x, currentPoint.y + l * y);
                    CGPoint controlPoint0 = ((NSValue *)allPoints[0]).CGPointValue;
                    CGPoint controlPoint0_ = CGPointMake(controlPoint0.x + l * x, controlPoint0.y + l * y);
                    CGPoint controlPoint1 = ((NSValue *)allPoints[1]).CGPointValue;
                    CGPoint controlPoint1_ = CGPointMake(controlPoint1.x + l * x, controlPoint1.y + l * y);
                    CGPoint curveEndPoint = ((NSValue *)allPoints[2]).CGPointValue;
                    CGPoint curveEndPoint_ = CGPointMake(curveEndPoint.x + l * x, curveEndPoint.y + l * y);
                    
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
            }
        }
    }
}

@end
