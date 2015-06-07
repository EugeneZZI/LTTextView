//
//  LTLinkTextView.h
//  
//
//  Created by Eugene Zozulya on 3/29/15.
//  Copyright (c) 2015 Eugene Zozulya. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const    LTTextStringParameterKey; // key for title NSString

@class LTLinkTextView;

@protocol LTLinkTextViewDelegate <NSObject>

@optional
- (void)linkTextView:(LTLinkTextView*)termsTextView didSelectButtonWithIndex:(NSUInteger)buttonIndex title:(NSString*)title;

@end

@interface LTLinkTextView : UIView

@property (nonatomic, weak) id<LTLinkTextViewDelegate>                       delegate;

- (void)setStringAttributes:(NSDictionary*)textInfo withButtonsStringsAttributes:(NSArray*)buttonsStringsInfo; // buttonsStringsInfo array of dictionaries

@end
