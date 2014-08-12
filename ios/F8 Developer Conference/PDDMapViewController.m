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

#import "PDDMapViewController.h"
#import "PDDMapView.h"
#import "PDDAppDelegate.h"

@interface PDDMapViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) PDDMapView *mapView;
@property (strong, nonatomic) NSDictionary *mapInfo;
@end

@implementation PDDMapViewController

#pragma mark - Initialization methods
- (id)initWithData:(NSDictionary *)data atPageIndex:(NSInteger)pageIndex {
    self = [super init];
    if (self) {
        _mapInfo = data;
        _pageIndex = pageIndex;
        
        self.title = data[@"title"];
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)loadView {
    PDDMapView *mapView = [[PDDMapView alloc] initWithImage:self.mapInfo[@"image"]];
    mapView.delegate = self;
    self.mapView = mapView;
    self.view = mapView;
}

#pragma mark - UIScrollView delegate methods
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mapView.mapImageView;
}

@end
