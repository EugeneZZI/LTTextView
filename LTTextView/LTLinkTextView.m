//
//  LTLinkTextView.m
//
//
//  Created by Eugene Zozulya on 3/29/15.
//  Copyright (c) 2015 Eugene Zozulya. All rights reserved.
//

#import "LTLinkTextView.h"
#import <CoreText/CoreText.h>

NSString *const     LTTextStringParameterKey              = @"_LTTextStringParameterKey";

@interface LTButtonString : NSObject

@property (nonatomic, copy) NSString                            *text;
@property (nonatomic, readonly, strong) NSMutableArray          *frames;
@property (nonatomic, assign) NSRange                            range;

@end

@interface LTLinkTextView() {
    CGSize                                   _oldSize;
    NSString                                *_currentString;
    NSDictionary                            *_currentStringAttributes;
    NSArray                                 *_currentButtonsStringAttributes; // array of dictionaries
    NSMutableAttributedString               *_fullString;
    NSMutableArray                          *_buttonsStrings; // array of ButtonStrings
}

@end

@implementation LTLinkTextView

- (instancetype)init {
    self = [super init];
    if(self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setStringAttributes:(NSDictionary*)textInfo withButtonsStringsAttributes:(NSArray*)buttonsStringsInfo; {
    NSString *text = textInfo[LTTextStringParameterKey];
    if(![text isEqual:_currentString]) {
        _currentString = text;
        _currentStringAttributes = textInfo;
        _currentButtonsStringAttributes = buttonsStringsInfo;
        
        [self checkButtonsAttributes];
        // redraw vew with new string
        _oldSize = CGSizeZero;
        [self setNeedsDisplay];
    }
}

#pragma mark - Private Methods

- (void)commonInit {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTap:(UITapGestureRecognizer*)sender {
    if(sender.state == UIGestureRecognizerStateEnded) {
        CGPoint tapLocation = [sender locationInView:self];
        
        [_buttonsStrings enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(LTButtonString *buttonString, NSUInteger idx, BOOL *stop) {
            CGRect buttonFrame = [buttonString.frames.firstObject CGRectValue];
            if(CGRectContainsPoint(buttonFrame, tapLocation)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self.delegate respondsToSelector:@selector(linkTextView:didSelectButtonWithIndex:title:)]) {
                        [self.delegate linkTextView:self didSelectButtonWithIndex:idx title:buttonString.text];
                    }
                });
                *stop = YES;
            }
        }];
    }
}

- (void)checkButtonsAttributes {
    NSMutableParagraphStyle *pStyle = _currentStringAttributes[NSParagraphStyleAttributeName];
    NSMutableArray *buttonsAttr     = [_currentButtonsStringAttributes mutableCopy];
    
    for(int i = 0; i < _currentButtonsStringAttributes.count; i++) {
        NSMutableDictionary *buttonAttr = [_currentButtonsStringAttributes[i] mutableCopy];
        
        if(pStyle)
            buttonAttr[NSParagraphStyleAttributeName] = pStyle;
        if(!buttonAttr[NSFontAttributeName] && _currentStringAttributes[NSFontAttributeName])
            buttonAttr[NSFontAttributeName] = _currentStringAttributes[NSFontAttributeName];
        if(!buttonAttr[NSForegroundColorAttributeName] && _currentStringAttributes[NSForegroundColorAttributeName])
            buttonAttr[NSForegroundColorAttributeName] = _currentStringAttributes[NSForegroundColorAttributeName];
        
        buttonsAttr[i] = [buttonAttr copy];
    }
    
    _currentButtonsStringAttributes = [buttonsAttr copy];
}

- (void)formatCurrentString {
    _buttonsStrings = [NSMutableArray new];
    
    NSMutableAttributedString *attrFullString = [[NSMutableAttributedString alloc] initWithString:_currentString];
    NSDictionary *attributes = _currentStringAttributes;
    [attrFullString setAttributes:attributes range:NSMakeRange(0, _currentString.length)];
    _fullString = attrFullString;
    
    for (NSDictionary *buttonInfo in _currentButtonsStringAttributes) {
        NSString *buttonText = buttonInfo[LTTextStringParameterKey];
        NSRange range = [_currentString rangeOfString:buttonText];
        
        if (range.location != NSNotFound) {
            LTButtonString *btnStr = [LTButtonString new];
            btnStr.text = buttonText;
            btnStr.range = range;
            [_buttonsStrings addObject:btnStr];
            
            [attrFullString setAttributes:buttonInfo range:range];
        }
    }
}

- (BOOL)updateFormattingWithButtonsStrings:(NSArray*)newButtonsStrings {
    if(!newButtonsStrings.count)
        return NO;
    
    BOOL retFlag = NO;
    LTButtonString *buttonString = newButtonsStrings.firstObject;
    
    NSMutableString *mutableString = [[NSMutableString alloc] initWithString:_currentString];
    CGPathRef path = CGPathCreateWithRect(self.bounds, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_fullString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, [_fullString length]), path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSArray *linesArr = (__bridge NSArray*)lines;
    
    for (id line in linesArr) {
        CFRange range = CTLineGetStringRange((CTLineRef)line);
        if((buttonString.range.location >= range.location && buttonString.range.location <= (range.location + range.length)) &&
           ((buttonString.range.location+buttonString.range.length) > (range.location + range.length)))
        {
            [mutableString insertString:@"\r" atIndex:buttonString.range.location];
            retFlag = YES;
            break;
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    _currentString = mutableString;
    [self formatCurrentString];
    
    NSMutableArray *newArr = [newButtonsStrings mutableCopy];
    [newArr removeObjectAtIndex:0];
    BOOL flag = [self updateFormattingWithButtonsStrings:newArr];
    return flag || retFlag;
}

- (CGFloat)getWidthForButtonAttributes:(NSDictionary*)buttonInfo {
    NSString *buttonText = buttonInfo[LTTextStringParameterKey];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:buttonText];
    [attrString setAttributes:buttonInfo range:NSMakeRange(0, buttonText.length)];
    
    CGFloat fontSize = [UIFont systemFontOfSize:[UIFont labelFontSize]].pointSize - 4.0;
    UIFont *buttonFont = buttonInfo[NSFontAttributeName];
    if(buttonFont)
        fontSize = buttonFont.pointSize;

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), fontSize+5), NULL);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, [buttonText length]), path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSArray *linesArr = (__bridge NSArray*)lines;
    CGFloat width = CTLineGetTypographicBounds((CTLineRef)linesArr.firstObject, NULL, NULL, NULL);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    return width;
}

- (BOOL)isNewSize:(CGSize)newSize {
    if(newSize.width != _oldSize.width)
        return YES;
    if(newSize.height != _oldSize.height)
        return YES;
    
    return NO;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if ([self isNewSize:rect.size] && _currentString) {
        _oldSize = rect.size;
        
        [self formatCurrentString];
        [self updateFormattingWithButtonsStrings:_buttonsStrings];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGPathRef path = CGPathCreateWithRect(self.bounds, NULL);
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_fullString);
        if(framesetter) {
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                        CFRangeMake(0, [_fullString length]), path, NULL);
            CTFrameDraw(frame, context);
            
            CFArrayRef lines = CTFrameGetLines(frame);
            NSArray *linesArr = (__bridge NSArray*)lines;
            CGPoint origins[linesArr.count];
            
            CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
            for (int n = 0; n < _buttonsStrings.count; n++) {
                LTButtonString *buttonString = _buttonsStrings[n];
                [buttonString.frames removeAllObjects];
                NSDictionary *buttonInfo = _currentButtonsStringAttributes[n];
                for (int i = 0; i < linesArr.count; i++) {
                    CTLineRef line = (__bridge CTLineRef)linesArr[i];
                    CFRange range = CTLineGetStringRange(line);
                    if(buttonString.range.location >= range.location && buttonString.range.location < (range.location + range.length)) {
                        CGFloat fontSize = [UIFont systemFontOfSize:[UIFont labelFontSize]].pointSize - 4.0;
                        UIFont *buttonFont = buttonInfo[NSFontAttributeName];
                        if(buttonFont)
                            fontSize = buttonFont.pointSize;
                        
                        CGFloat startFloat = CTLineGetOffsetForStringIndex(line, buttonString.range.location, NULL);
                        CGRect buttonFrame = CGRectMake(startFloat + origins[i].x, (CGRectGetHeight(self.bounds) - fontSize - origins[i].y + 2.0), [self getWidthForButtonAttributes:buttonInfo], fontSize);
                        NSValue *frameValue = [NSValue valueWithCGRect:buttonFrame];
                        [buttonString.frames addObject:frameValue];
                    }
                }
            }
            
            CFRelease(frame);
            CFRelease(path);
            CFRelease(framesetter);
        }
    }
}

@end

@implementation LTButtonString

- (instancetype)init {
    self = [super init];
    if(self) {
        _frames = [NSMutableArray new];
    }
    
    return self;
}

@end
