/**
 * Copyright 2014 Facebook, Inc.
 *
 * You are hereby granted a non-exclusive, worldwide, royalty-free license to
 * use, copy, modify, and distribute this software in source code or binary
 * form for use in connection with the web services and APIs provided by
 * Facebook.
 *
 * As with any software that integrates with the Facebook platform, your use
 * of this software is subject to the Facebook Developer Principles and
 * Policies [http://developers.facebook.com/policy/]. This copyright notice
 * shall be included in all copies or substantial portions of the software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */

#import "PDDLoginViewController.h"
#import "PDDWebViewController.h"

#import "UIColor+PDD.h"
#import "UIFont+PDD.h"

@interface PDDLoginViewController ()
@property (weak, nonatomic) UITextView *termsPrivacyTextView;
@end

@implementation PDDLoginViewController

#pragma mark - Initialization methods
- (id)init {
    self = [super init];
    if (self) {
        self.fields = PFLogInFieldsFacebook;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.fields = PFLogInFieldsFacebook;
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:
                                 [UIImage imageNamed:@"loginBackground"]];
    
    [self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setImage:[UIImage imageNamed:@"fblogin"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:[UIImage imageNamed:@"fblogin-pressed"] forState:UIControlStateSelected];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    UIImageView *loginLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLogo"]];
    self.logInView.logo = loginLogoImageView;
    
    UITextView *termsPrivacyTextView = [[UITextView alloc] init];
    termsPrivacyTextView.backgroundColor = [UIColor clearColor];
    termsPrivacyTextView.editable = NO;
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont pddBody],
                                 NSForegroundColorAttributeName: [UIColor pddTextColor],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    NSMutableAttributedString *termsPrivacyTextViewText = [[NSMutableAttributedString alloc] initWithString:@"By logging in, you agree to our Terms and Privacy Policy." attributes:attributes];
    NSRange termsRange = (NSRange){32,5};
    NSRange privacyRange = (NSRange){42,14};
    NSURL *termsURL = [NSURL URLWithString:@"https://m.facebook.com/legal/terms"];
    NSURL *privacyURL = [NSURL URLWithString:@"https://m.facebook.com/policies?_rdr"];
    [termsPrivacyTextViewText addAttribute:NSLinkAttributeName
                                  value:termsURL
                                  range:termsRange];
    [termsPrivacyTextViewText addAttribute:NSLinkAttributeName
                                  value:privacyURL
                                  range:privacyRange];
    termsPrivacyTextView.linkTextAttributes = @{
                                             NSForegroundColorAttributeName: [UIColor pddTextColor],
                                             NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                             };
    termsPrivacyTextView.attributedText = [termsPrivacyTextViewText copy];
    
    [self.logInView addSubview:termsPrivacyTextView];
    self.termsPrivacyTextView = termsPrivacyTextView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat changeOffsetY = 100;
    CGRect loginViewFrame = self.logInView.facebookButton.frame;
    loginViewFrame.origin.y += changeOffsetY;
    UIImage *facebookButtonImage = [UIImage imageNamed:@"fblogin"];
    loginViewFrame.size = facebookButtonImage.size;
    self.logInView.facebookButton.frame = loginViewFrame;
    CGRect loginLogoFrame = self.logInView.logo.frame;
    loginLogoFrame.origin.y += changeOffsetY;
    self.logInView.logo.frame = loginLogoFrame;
    
    changeOffsetY = loginViewFrame.origin.y + loginViewFrame.size.height + 10;
    CGFloat termsPrivacyTextViewWidth = 200;
    CGFloat termsPrivacyTextViewOffsetX = (CGRectGetWidth(self.view.bounds) - termsPrivacyTextViewWidth) / 2;
    CGRect termsPrivacyFrame = CGRectMake(termsPrivacyTextViewOffsetX, changeOffsetY, termsPrivacyTextViewWidth, 40);
    self.termsPrivacyTextView.frame = termsPrivacyFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods
- (void) _openTermsOfServiceURL: (UITapGestureRecognizer *) sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.facebook.com/legal/terms"]];
}

- (void) _openPrivacyPolicyURL: (UITapGestureRecognizer *) sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.facebook.com/policies?_rdr"]];
}

@end
