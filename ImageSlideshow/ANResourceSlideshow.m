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
        [scrollView setPagingEnabled:YES];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setScrollEnabled:YES];
        imageViews = [[NSMutableArray alloc] initWithCapacity:5];
        [self.view addSubview:scrollView];
        
        [self resetToPage:0];
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
    
    NSUInteger firstIndex = 0;
    if (currentImage > 2) {
        firstIndex = currentImage - 2;
    }
    if (firstIndex + 5 > [imageURLs count] && firstIndex > 0) {
        NSUInteger overflow = (firstIndex + 5) - [imageURLs count];
        if (firstIndex >= overflow) {
            firstIndex -= overflow;
        } else {
            firstIndex = 0;
        }
    }
    for (int i = 0; i < 5; i++) {
        NSUInteger index = firstIndex + i;
        if (index == pageIndex) {
            imageViewIndex = i;
        }
        CGRect imageFrame = [self frameForPageIndex:index];
        ANAsyncImageView * imageView = [[ANAsyncImageView alloc] initWithFrame:imageFrame];
        if (index < [imageURLs count]) {
            [imageView loadImageURL:[imageURLs objectAtIndex:index]];
            [scrollView addSubview:imageView];
        } else break;
        [imageViews addObject:imageView];
    }
    currentImage = pageIndex;
}

- (void)loadCachesAroundCurrentPage {
    
}

- (void)dealloc {
    [imageURLs release];
    [imageViews release];
    [scrollView release];
    [super dealloc];
}

@end
