//
//  ANResourceSlideshow.m
//  ImageSlideshow
//
//  Created by Alex Nichol on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANResourceSlideshow.h"

@implementation ANResourceSlideshow

- (id)initWithImageURLs:(NSArray *)urls {
    if ((self = [super init])) {
#if !__has_feature(objc_arc)
        imageURLs = [urls retain];
#else
        imageURLs = urls;
#endif
        CGSize size = self.view.bounds.size;
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [scrollView setContentSize:CGSizeMake([urls count] * size.width, size.height)];
    }
    return self;
}

- (CGRect)frameForPageIndex:(NSUInteger)pageIndex {
    return CGRectMake(pageIndex * scrollView.frame.size.width, 0,
                      scrollView.frame.size.width, scrollView.frame.size.height);
}

- (void)resetToPage:(NSUInteger)pageIndex {
    // unload the current image views
    for (UIView * view in imageViews) {
        if ([view superview]) {
            [view removeFromSuperview];
        }
    }
    [imageViews removeAllObjects];
    
}

- (void)loadCachesAroundCurrentPage {
    
}

- (void)dealloc {
    [imageURLs release];
    [scrollView release];
    [super dealloc];
}

@end
