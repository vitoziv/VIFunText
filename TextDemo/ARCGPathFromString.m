//
//  ARCGPathFromString.m
//  TextDemo
//
//  Created by Vito on 06/11/2016.
//  Copyright © 2016 Vito. All rights reserved.
//

#import "ARCGPathFromString.h"
@import UIKit;

#pragma mark Single Line String Path

CGPathRef CGPathCreateSingleLineStringWithAttributedString(NSAttributedString *attrString)
{
    CGMutablePathRef letters = CGPathCreateMutable();
    
    
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
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
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    
    CFRelease(line);
    
    CGPathRef finalPath = CGPathCreateCopy(letters);
    CGPathRelease(letters);
    return finalPath;
}


#pragma mark - Multiple Line String Path

CGPathRef CGPathCreateMultilineStringWithAttributedString(NSAttributedString *attrString, CGFloat maxWidth, CGFloat maxHeight)
{
    
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CGRect bounds = CGRectMake(0, 0, maxWidth, maxHeight);
    
    CGPathRef pathRef = CGPathCreateWithRect(bounds, NULL);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attrString));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), pathRef, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    CGPoint *points = malloc(sizeof(CGPoint) * CFArrayGetCount(lines));
    
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
    
    NSInteger numLines = CFArrayGetCount(lines);
    // for each LINE
    for (CFIndex lineIndex = 0; lineIndex < numLines; lineIndex++)
    {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CFRange r = CTLineGetStringRange(lineRef);
        
        NSParagraphStyle *paragraphStyle = [attrString attribute:NSParagraphStyleAttributeName atIndex:r.location effectiveRange:NULL];
        NSTextAlignment alignment = paragraphStyle.alignment;
        
        
        CGFloat flushFactor = 0.0;
        if (alignment == NSTextAlignmentLeft) {
            flushFactor = 0.0;
        } else if (alignment == NSTextAlignmentCenter) {
            flushFactor = 0.5;
        } else if (alignment == NSTextAlignmentRight) {
            flushFactor = 1.0;
        }
        
        
        
        CGFloat penOffset = CTLineGetPenOffsetForFlush(lineRef, flushFactor, maxWidth);
        
        // create a new justified line if the alignment is justified
        if (alignment == NSTextAlignmentJustified) {
            lineRef = CTLineCreateJustifiedLine(lineRef, 1.0, maxWidth);
            penOffset = 0;
        }
        
        CGFloat lineOffset = numLines == 1 ? 0 : maxHeight - points[lineIndex].y;
        
        CFArrayRef runArray = CTLineGetGlyphRuns(lineRef);
        
        // for each RUN
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
                
                position.y -= lineOffset;
                position.x += penOffset;
                
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
        
        // if the text is justified then release the new justified line we created.
        if (alignment == NSTextAlignmentJustified) {
            CFRelease(lineRef);
        }
    }
    
    free(points);
    
    CGPathRelease(pathRef);
    CFRelease(frame);
    CFRelease(framesetter);
    
    CGRect pathBounds = CGPathGetBoundingBox(letters);
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-pathBounds.origin.x, -pathBounds.origin.y);
    CGPathRef finalPath = CGPathCreateCopyByTransformingPath(letters, &transform);
    CGPathRelease(letters);
    
    return finalPath;
}
