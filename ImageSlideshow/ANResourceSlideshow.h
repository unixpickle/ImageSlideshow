//
//  ANResourceSlideshow.h
//  ImageSlideshow
//
//  Created by Alex Nichol on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANResourceSlideshow : UIViewController {
    NSArray * imageURLs;
    UIScrollView * scrollView;
    
    NSUInteger currentImage;
    
    NSUInteger imageViewIndex;
    NSMutableArray * imageViews;
}

- (id)initWithImageURLs:(NSArray *)urls;

- (CGRect)frameForPageIndex:(NSUInteger)pageIndex;
- (void)resetToPage:(NSUInteger)pageIndex;
- (void)loadCachesAroundCurrentPage;

@end
