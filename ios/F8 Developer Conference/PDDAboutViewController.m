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

#import "PDDAboutViewController.h"
#import "PDDAboutView.h"

@interface PDDAboutViewController ()
@property (strong, nonatomic) NSString *aboutText;
@property (weak, nonatomic) PDDAboutView *aboutView;
@end

@implementation PDDAboutViewController

#pragma mark - Initialization methods
- (id)init {
    self = [super init];
    if (self) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"F8Notices" ofType:@"txt"];
        _aboutText = [[NSString alloc] initWithContentsOfFile:filePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
        
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)loadView {
    UIView *view = [[UIView alloc] init];
    
    PDDAboutView *aboutView = [[PDDAboutView alloc] initWithText:self.aboutText];
    [view addSubview:aboutView];
    self.aboutView = aboutView;
    
    self.view = view;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
