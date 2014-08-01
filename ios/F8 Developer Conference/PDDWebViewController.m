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

#import "PDDWebViewController.h"
#import "UIColor+PDD.h"

@interface PDDWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString *webURL;
@end

@implementation PDDWebViewController

#pragma mark - Initialization methods
- (id)initWithURL:(NSString *)webURL title:(NSString *)title {
    self = [super init];
    if (self) {
        // Custom initialization
        _webURL = webURL;
        self.title = title;
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    webView.backgroundColor = [UIColor pddContentBackgroundColor];
    webView.scalesPageToFit = YES;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webView.delegate = self;
    self.webView = webView;
    [self.view addSubview:webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webURL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.webView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.webView.delegate = nil;
     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UIWebView delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
