//
//  ANResourceSlideshow.h
//  ImageSlideshow
//
//  Created by Alex Nichol on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANAsyncImageView.h"

@interface ANResourceSlideshow : UIViewController <UIScrollViewDelegate> {
    NSArray * imageURLs;
    UIScrollView * scrollView;
    
    NSUInteger currentPage;
    
    NSUInteger firstImageIndex;
    NSMutableArray * imageViews;
    BOOL wasStatusHidden;
}

- (id)initWithImageURLs:(NSArray *)urls;

- (CGRect)frameForPageIndex:(NSUInteger)pageIndex;
- (void)resetToPage:(NSUInteger)pageIndex;
- (void)loadCachesAroundCurrentPage;

@end
