//
//  ViewController.m
//  TextDemo
//
//  Created by Vito on 06/11/2016.
//  Copyright © 2016 Vito. All rights reserved.
//

#import "ViewController.h"
#import "UIBezierPath+TextPaths.h"
@import CoreGraphics;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *str = @"1好害pia";
    UIFont *font = [UIFont systemFontOfSize:55];
    UIBezierPath *path = [UIBezierPath pathForString:str withFont:font];
    [path applyTransform:CGAffineTransformMakeTranslation(-path.bounds.origin.x, -path.bounds.size.height - path.bounds.origin.y)];
    [path applyTransform:CGAffineTransformMakeScale(1.0, -1.0)];
    
    [self drawPath:path toCenter:CGPointMake(100, 100)];
    
    
    UIBezierPath *path1 = [self applyEffectToPath:path];
    [self drawPath:path1 toCenter:CGPointMake(100, 200)];
    
    UIBezierPath *path2 = [self applyEffectToPath:path];
    [self drawPath:path2 toCenter:CGPointMake(100, 300)];
    
    // Path animation
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = CGRectMake(100, 400, 100, 100);
    layer.path = path.CGPath;
    [self.view.layer addSublayer:layer];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    animation.duration = 3;
    animation.repeatCount = NSIntegerMax;
    animation.autoreverses = YES;
    animation.values = @[(id)path.CGPath, (id)path1.CGPath, (id)path2.CGPath];
    
    [layer addAnimation:animation forKey:nil];
    
    
    // Images animations
    [self drawImageViewFromPaths:@[path, path1, path2] center:CGPointMake(100, 500)];
}

- (void)drawPath:(UIBezierPath *)path toCenter:(CGPoint)center {
    CGSize size = CGSizeMake(path.bounds.size.width, path.bounds.size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor orangeColor] set];
    [path stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.backgroundColor = [UIColor lightGrayColor];
    imageView.center = center;
    [self.view addSubview:imageView];
}

- (void)drawImageViewFromPaths:(NSArray *)paths center:(CGPoint)center {
    NSMutableArray *images = [NSMutableArray array];
    for (UIBezierPath *path in paths) {
        CGSize size = CGSizeMake(path.bounds.size.width, path.bounds.size.height);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        [[UIColor orangeColor] set];
        [path stroke];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
    }
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor lightGrayColor];
    imageView.bounds = CGRectMake(0, 0, 210, 100);
    imageView.center = center;
    imageView.animationImages = images;
    imageView.animationDuration = 0.3;
    [imageView startAnimating];
    [self.view addSubview:imageView];
}

- (UIBezierPath *)applyEffectToPath:(UIBezierPath *)path {
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(path.CGPath, (__bridge void * _Nullable)(points), applierFunctionCallback);
    if ([points[0] isKindOfClass:[NSNumber class]] && ![points[0] boolValue]) {
        return nil;
    }
    
    return [self createBesizerPathFromInfo:points];
}

- (UIBezierPath *)createBesizerPathFromInfo:(NSArray *)info {
    if (!info) return nil;
    
    // Recreate (and store) path
    CGMutablePathRef p = CGPathCreateMutable();
    CGPathMoveToPoint(p, NULL, 0, 0);
    for (NSInteger i = 1, l = [info count]; i < l; i++) {
        NSDictionary *d = [info objectAtIndex:i];
        
        NSArray *points = d[@"points"];
        switch ([d[@"type"] intValue]) {
            case kCGPathElementMoveToPoint:
                CGPathMoveToPoint(p, NULL, [points[0] CGPointValue].x, [points[0] CGPointValue].y);
                break;
            case kCGPathElementAddLineToPoint:
                CGPathAddLineToPoint(p, NULL, [points[0] CGPointValue].x, [points[0] CGPointValue].y);
                break;
            case kCGPathElementAddQuadCurveToPoint:
                CGPathAddQuadCurveToPoint(p, NULL, [points[0] CGPointValue].x, [points[0] CGPointValue].y, [points[1] CGPointValue].x, [points[1] CGPointValue].y);
                break;
            case kCGPathElementAddCurveToPoint:
                CGPathAddCurveToPoint(p, NULL, [points[0] CGPointValue].x, [points[0] CGPointValue].y, [points[1] CGPointValue].x, [points[1] CGPointValue].y, [points[2] CGPointValue].x, [points[2] CGPointValue].y);
                break;
            case kCGPathElementCloseSubpath:
                CGPathCloseSubpath(p);
                break;
            default:
                CGPathRelease(p);
                return nil;
        }
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:p];
    path.lineJoinStyle = kCGLineJoinRound;
    CGPathRelease(p);
    
    return path;
}


/**
 在这里处理 path 中的每一个 point，根据具体需求调整每个 point 的位置
 */
void applierFunctionCallback(void *info, const CGPathElement *element) {
    NSMutableArray *a = (__bridge NSMutableArray *)info;
    CGPoint *ps = element->points;
    NSMutableArray *points = [NSMutableArray array];
    switch (element->type) {
        case kCGPathElementMoveToPoint: {
            CGPoint p0 = ps[0];
//            randomPoint(&p0);
            [points addObject:[NSValue valueWithCGPoint:p0]];
        }
            break;
        case kCGPathElementAddLineToPoint: {
            CGPoint p0 = ps[0];
            randomPoint(&p0);
            [points addObject:[NSValue valueWithCGPoint:p0]];
        }
            break;
        case kCGPathElementAddQuadCurveToPoint: {
            CGPoint p0 = ps[0];
            CGPoint p1 = ps[1];
//            randomPoint(&p0);
//            randomPoint(&p1);
            [points addObject:[NSValue valueWithCGPoint:p0]];
            [points addObject:[NSValue valueWithCGPoint:p1]];
        }
            break;
        case kCGPathElementAddCurveToPoint: {
            CGPoint p0 = ps[0];
            CGPoint p1 = ps[1];
            CGPoint p2 = ps[2];
//            randomPoint(&p0);
            randomPoint(&p1);
            randomPoint(&p2);
            [points addObject:[NSValue valueWithCGPoint:p0]];
            [points addObject:[NSValue valueWithCGPoint:p1]];
            [points addObject:[NSValue valueWithCGPoint:p2]];
        }
            break;
        case kCGPathElementCloseSubpath:
            break;
        default:
            a[0] = @NO;
            return;
    }
    
    NSNumber *type = @(element->type);
    [a addObject:@{@"type": type, @"points": points}];
}


void randomPoint(CGPoint *point) {
    float randomValue = 0.2;
    (*point).x += ((arc4random() % 101) * 0.1) * (arc4random() % 2 == 0 ? randomValue : -randomValue);
    (*point).x = MAX(0, (*point).x);
    (*point).y += ((arc4random() % 101) * 0.1) * (arc4random() % 2 == 0 ? randomValue : -randomValue);
    (*point).y = MAX(0, (*point).y);
}

@end
