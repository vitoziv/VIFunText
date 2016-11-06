//
//  UIBezierPath+TextPaths.m
//  TextDemo
//
//  Created by Vito on 06/11/2016.
//  Copyright © 2016 Vito. All rights reserved.
//

#import "UIBezierPath+TextPaths.h"

#import "UIBezierPath+TextPaths.h"
#import "ARCGPathFromString.h"


// for the multiline the CTFrame must have a max path size. This value is arbitrary, currently 4x the height of ipad screen.
#define MAX_HEIGHT_OF_FRAME 4096




@implementation UIBezierPath (TextPaths)


#pragma mark - NSString


+ (UIBezierPath *)pathForString:(NSString *)string withFont:(UIFont *)font
{
    // if there is no string or font then just return nil.
    if (!string || !font) return nil;
    
    // create the dictionary of attributes for the attributed string contaning the font.
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    
    // create the attributed string.
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    // create path from attributed string.
    return [self pathForAttributedString:attrString];
}


+ (UIBezierPath *)pathForMultilineString:(NSString *)string
                                withFont:(UIFont *)font
                                maxWidth:(CGFloat)maxWidth
                           textAlignment:(NSTextAlignment)alignment

{
    // if there is no string or font or no width then just return nil.
    if (!string || !font || maxWidth <= 0.0) return nil;
    
    // create the paragraph style so the text alignment can be assigned to the attributed string.
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = alignment;
    
    // create the dictionary of attributes for the attributed string contaning the font and the paragraph style with the text alignment.
    NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle };
    
    // create the attributed string.
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    // create path for attributed string.
    return [self pathForMultilineAttributedString:attrString maxWidth:maxWidth];
}


#pragma mark - NSAttributedString


+ (UIBezierPath *)pathForAttributedString:(NSAttributedString *)string
{
    // if there is no specified string then there will be no path so just return nil.
    if (!string) return nil;
    
    // create the path from the specified string.
    CGPathRef letters = CGPathCreateSingleLineStringWithAttributedString(string);
    
    // make an iOS UIBezierPath object from the CGPath.
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:letters];
    
    // release the created CGPath.
    CGPathRelease(letters);
    
    return path;
}


+ (UIBezierPath *)pathForMultilineAttributedString:(NSAttributedString *)string maxWidth:(CGFloat)maxWidth
{
    // if there is no specified string or the maxwidth is set to 0 then there will be no path so return nil.
    if (!string || maxWidth <= 0.0) return nil;
    
    // create the path from the specified string.
    CGPathRef letters = CGPathCreateMultilineStringWithAttributedString(string, maxWidth, MAX_HEIGHT_OF_FRAME);
    
    // make an iOS UIBezierPath object from the CGPath.
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:letters];
    
    // release the created CGPath.
    CGPathRelease(letters);
    
    return path;
}





@end
