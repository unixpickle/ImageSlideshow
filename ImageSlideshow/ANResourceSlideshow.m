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
    }
    return self;
}

- (CGRect)frameForPageIndex:(NSUInteger)pageIndex {
    return CGRectMake(pageIndex * scrollView.frame.size.width, 0,
                      scrollView.frame.size.width, scrollView.frame.size.height);
}

- (void)resetToPage:(NSUInteger)pageIndex {
    
}

- (void)loadCachesAroundCurrentPage {
    
}

- (void)dealloc {
    [imageURLs release];
    [scrollView release];
    [super dealloc];
}

@end
