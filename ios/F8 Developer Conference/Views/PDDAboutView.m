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

#import "PDDAboutView.h"
#import "UIColor+PDD.h"
#import "UIFont+PDD.h"

@implementation PDDAboutView

- (id)initWithText:(NSString *)text {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor pddContentBackgroundColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // TextView
        UITextView *textView = [[UITextView alloc] init];
        [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = [UIColor pddTextColor];
        textView.font = [UIFont pddBody];
        
        textView.text = text;
        textView.editable = NO;
        [self addSubview:textView];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(textView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[textView]-15-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(textView)]];
    }
    return self;
}

@end
