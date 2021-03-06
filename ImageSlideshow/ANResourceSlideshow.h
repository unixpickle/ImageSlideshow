//
//  ANResourceSlideshow.h
//  ImageSlideshow
//
//  Created by Alex Nichol on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANAsyncImageView.h"
#import "TapScrollView.h"

@interface ANResourceSlideshow : UIViewController <UIScrollViewDelegate> {
    NSArray * imageURLs;
    UIScrollView * scrollView;
    
    NSUInteger currentPage;
    
    NSUInteger firstImageIndex;
    NSMutableArray * imageViews;
    BOOL wasStatusHidden;
    
    UIStatusBarStyle initialBarStyle;
    BOOL initialBarHidden;
    
    UINavigationBar * navigationBar;
    UIBarButtonItem * doneButton;
    BOOL isShowingControls;
}

- (id)initWithImageURLs:(NSArray *)urls;

- (CGRect)frameForPageIndex:(NSUInteger)pageIndex;
- (void)resetToPage:(NSUInteger)pageIndex;
- (void)loadCachesAroundCurrentPage;

- (void)doneSlideshow:(id)sender;

@end
