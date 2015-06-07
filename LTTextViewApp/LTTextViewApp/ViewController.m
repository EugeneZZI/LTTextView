//
//  ViewController.m
//  LTTextViewApp
//
//  Created by ZZI on 29/05/15.
//  Copyright (c) 2015 ZZICo. All rights reserved.
//

#import "ViewController.h"
#import "LTLinkTextView.h"

@interface ViewController () <LTLinkTextViewDelegate>

@property (weak, nonatomic) IBOutlet LTLinkTextView *firstLTView;
@property (weak, nonatomic) IBOutlet LTLinkTextView *secondLTView;
@property (weak, nonatomic) IBOutlet LTLinkTextView *thirdLTView;
@property (weak, nonatomic) IBOutlet LTLinkTextView *fourthLTView;
@property (weak, nonatomic) IBOutlet LTLinkTextView *fifthLTView;
@property (weak, nonatomic) IBOutlet LTLinkTextView *sixthLTView;

@property (weak, nonatomic) IBOutlet UILabel        *messageLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    dispatch_apply(6, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
        NSString *selectorStr = [NSString stringWithFormat:@"setupLTView%d", (int)++i];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:NSSelectorFromString(selectorStr)];
        });
    });
#pragma clang diagnostic pop
    
    [self setupLTView4];
}

- (void)setupLTView1 {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:6.0];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    
    NSDictionary *textAttributes = @{LTTextStringParameterKey : NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa.", @""),
                                     NSFontAttributeName : [UIFont systemFontOfSize:12.0]};
    
    NSArray *buttonsAttributes = @[@{LTTextStringParameterKey : NSLocalizedString(@"ligula eget dolor", @""),
                                     NSForegroundColorAttributeName : [UIColor blueColor]}
                                   ];
    
    [self.firstLTView setStringAttributes:textAttributes withButtonsStringsAttributes:buttonsAttributes];
    self.firstLTView.delegate  = self;
    self.firstLTView.tag = 1;
}

- (void)setupLTView2 {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *textAttributes = @{LTTextStringParameterKey : NSLocalizedString(@"Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", @""),
                                     NSParagraphStyleAttributeName : paragraphStyle,
                                     NSFontAttributeName : [UIFont fontWithName:@"HoeflerText-Regular" size:12]};
    
    NSArray *buttonsAttributes = @[@{LTTextStringParameterKey : NSLocalizedString(@"Cum sociis", @""),
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)},
                                   @{LTTextStringParameterKey : NSLocalizedString(@"nascetur ridiculus", @""),
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}
                                   ];
    
    [self.secondLTView setStringAttributes:textAttributes withButtonsStringsAttributes:buttonsAttributes];
    self.secondLTView.delegate  = self;
    self.secondLTView.tag = 2;
}

- (void)setupLTView3 {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentRight;
    
    NSDictionary *textAttributes = @{LTTextStringParameterKey : NSLocalizedString(@"Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.", @""),
                                     NSParagraphStyleAttributeName : paragraphStyle,
                                     NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12]};
    
    NSArray *buttonsAttributes = @[@{LTTextStringParameterKey : NSLocalizedString(@"Nulla consequat", @""),
                                     NSForegroundColorAttributeName : [UIColor redColor],
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternDot)},
                                   @{LTTextStringParameterKey : NSLocalizedString(@"Donec pede", @""),
                                     NSForegroundColorAttributeName : [UIColor redColor],
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternDash)},
                                   @{LTTextStringParameterKey : NSLocalizedString(@"vulputate eget", @""),
                                     NSForegroundColorAttributeName : [UIColor redColor],
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternDashDot)}
                                   ];
    
    [self.thirdLTView setStringAttributes:textAttributes withButtonsStringsAttributes:buttonsAttributes];
    self.thirdLTView.delegate  = self;
    self.thirdLTView.tag = 3;
}

- (void)setupLTView4 {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *textAttributes = @{LTTextStringParameterKey : NSLocalizedString(@"In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium.", @""),
                                     NSParagraphStyleAttributeName : paragraphStyle};
    
    NSArray *buttonsAttributes = @[@{LTTextStringParameterKey : NSLocalizedString(@"rhoncus ut", @""),
                                     NSForegroundColorAttributeName : [UIColor blueColor],
                                     NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:10]},
                                   @{LTTextStringParameterKey : NSLocalizedString(@"Nullam dictum", @""),
                                     NSForegroundColorAttributeName : [UIColor grayColor],
                                     NSFontAttributeName : [UIFont fontWithName:@"HoeflerText-Regular" size:15]}
                                   ];
    
    [self.fourthLTView setStringAttributes:textAttributes withButtonsStringsAttributes:buttonsAttributes];
    self.fourthLTView.delegate  = self;
    self.fourthLTView.tag = 4;
}

- (void)setupLTView5 {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *textAttributes = @{LTTextStringParameterKey : NSLocalizedString(@"Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus.", @""),
                                     NSParagraphStyleAttributeName : paragraphStyle};
    
    NSArray *buttonsAttributes = @[@{LTTextStringParameterKey : NSLocalizedString(@"Cras dapibus.", @""),
                                     NSUnderlineColorAttributeName : [UIColor blueColor],
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)},
                                   @{LTTextStringParameterKey : NSLocalizedString(@"Aenean vulputate", @""),
                                     NSUnderlineColorAttributeName : [UIColor redColor],
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}
                                   ];
    
    [self.fifthLTView setStringAttributes:textAttributes withButtonsStringsAttributes:buttonsAttributes];
    self.fifthLTView.delegate  = self;
    self.fifthLTView.tag = 5;
}

- (void)setupLTView6 {
    NSDictionary *textAttributes = @{LTTextStringParameterKey : NSLocalizedString(@"By signing you are agreeing to the Terms and Conditions and Privacy Policy", @""),
                                     NSFontAttributeName : [UIFont systemFontOfSize:12],
                                     NSForegroundColorAttributeName : [UIColor grayColor]};
    
    NSArray *buttonsAttributes = @[@{LTTextStringParameterKey : NSLocalizedString(@"Terms and Conditions", @""),
                                     NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)},
                                   @{LTTextStringParameterKey : NSLocalizedString(@"Privacy Policy", @""),
                                     NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}
                                   ];
    
    [self.sixthLTView setStringAttributes:textAttributes withButtonsStringsAttributes:buttonsAttributes];
    self.sixthLTView.delegate  = self;
    self.sixthLTView.tag = 6;
}


#pragma mark - LTLinkTextViewDelegate

- (void)linkTextView:(LTLinkTextView*)termsTextView didSelectButtonWithIndex:(NSUInteger)buttonIndex title:(NSString*)title {
    NSString *messageStr = [NSString stringWithFormat:@"TextView: %d pushed button index: %d button text: \"%@\"", (int)termsTextView.tag, (int)buttonIndex, title];
    self.messageLabel.text = messageStr;
}

@end
