//
//  ARCGPathFromString.h
//  TextDemo
//
//  Created by Vito on 06/11/2016.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

/**
 Creates a CGPath from a specified attributed string.
 @param attrString The attributed string to produce the path for. Must not be `nil`.
 @return A new CGPath that contains a path with paths for all the glyphs for specifed string.
 @discussion  This string will always be on a single line even if the string contains linebreaks.
 */
CGPathRef CGPathCreateSingleLineStringWithAttributedString(NSAttributedString *attrString);

/**
 Creates a CGPath from a specified attributed string that can span over multiple lines of text.
 @param attrString The attributed string to produce the path for. Must not be `nil`.
 @param maxWidth   The maximum width of a line, if a line when rendered is longer than this width then the line is broken to a new line. Must be greater than 0.
 @param maxHeight  The maximum height of the text block. Must be greater than 0.
 @return A new CGPath that contains a path with paths for all the glyphs for specifed string.
 */
CGPathRef CGPathCreateMultilineStringWithAttributedString(NSAttributedString *attrString, CGFloat maxWidth, CGFloat maxHeight);
