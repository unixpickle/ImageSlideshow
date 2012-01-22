//
//  ANResourceSlideshow.m
//  ImageSlideshow
//
//  Created by Alex Nichol on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANResourceSlideshow.h"

@interface ANResourceSlideshow (Private)

- (NSUInteger)firstCacheIndexForIndex:(NSUInteger)index;

@end

@implementation ANResourceSlideshow

- (id)initWithImageURLs:(NSArray *)urls {
    if ((self = [super init])) {
        initialBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        initialBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
#if !__has_feature(objc_arc)
        imageURLs = [urls retain];
#else
        imageURLs = urls;
#endif
        CGSize size = self.view.bounds.size;
        scrollView = [[TapScrollView alloc] initWithFrame:self.view.bounds];
        [scrollView setContentSize:CGSizeMake([urls count] * size.width, size.height)];
        [scrollView setPagingEnabled:YES];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setScrollEnabled:YES];
        [scrollView setDelegate:self];
        imageViews = [[NSMutableArray alloc] initWithCapacity:5];
        [self.view addSubview:scrollView];
        
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
        [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
        UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:@"Slideshow"];
        [navigationBar setItems:[NSArray arrayWithObject:item]];
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSlideshow:)];
        item.rightBarButtonItem = doneButton;
        isShowingControls = NO;
        
        self.view.backgroundColor = [UIColor blackColor];
        
        [self resetToPage:0];
    }
    return self;
}

- (void)resetToPage:(NSUInteger)pageIndex {
    currentPage = pageIndex;

    // unload the current image views
    for (UIView * view in imageViews) {
        if ([view superview]) {
            [view removeFromSuperview];
        }
    }
    [imageViews removeAllObjects];
    
    NSUInteger firstIndex = [self firstCacheIndexForIndex:currentPage];
    firstImageIndex = firstIndex;
    
    for (int i = 0; i < 5 && firstIndex + i < [imageURLs count]; i++) {
        NSUInteger index = firstIndex + i;
        CGRect imageFrame = [self frameForPageIndex:index];
        ANAsyncImageView * imageView = [[ANAsyncImageView alloc] initWithFrame:imageFrame];
        [imageView loadImageURL:[imageURLs objectAtIndex:index]];
        [scrollView addSubview:imageView];
        [imageViews addObject:imageView];
#if !__has_feature(objc_arc)
        [imageView release];
#endif
    }
}

- (void)loadCachesAroundCurrentPage {
    NSUInteger firstIndex = [self firstCacheIndexForIndex:currentPage];
    if (firstIndex == firstImageIndex) {
        return; // already at current page.
    }
    
    NSRange reuseRange = NSMakeRange(0, [imageViews count]);
    if (firstIndex < firstImageIndex) {
        NSInteger numKeep = (NSInteger)[imageViews count] - (NSInteger)(firstImageIndex - firstIndex);
        if (numKeep > 0) {
            NSUInteger numReuse = [imageViews count] - numKeep;
            reuseRange = NSMakeRange([imageViews count] - numReuse, numReuse);
        }
        
        // move the end (reuse) chunk to the beginning
        NSArray * subArray = [imageViews subarrayWithRange:reuseRange];
        [imageViews removeObjectsInRange:reuseRange];
        for (NSUInteger i = 0; i < [subArray count]; i++) {
            [imageViews insertObject:[subArray objectAtIndex:i] atIndex:i];
        }
        
        // move reuse range to reflect our moved data
        reuseRange = NSMakeRange(0, [subArray count]);
    } else if (firstIndex > firstImageIndex) {
        NSInteger numKeep = (NSInteger)[imageViews count] - (NSInteger)(firstIndex - firstImageIndex);
        if (numKeep > 0) {
            NSUInteger numReuse = [imageViews count] - numKeep;
            reuseRange = NSMakeRange(0, numReuse);
        }
        
        // move the beginning (reuse) chunk to the end
        NSArray * subArray = [imageViews subarrayWithRange:reuseRange];
        [imageViews removeObjectsInRange:reuseRange];
        [imageViews addObjectsFromArray:subArray];
        
        // move reuse range to reflect our moved data
        reuseRange = NSMakeRange([imageViews count] - [subArray count], [subArray count]);
    }
    firstImageIndex = firstIndex;
    for (NSUInteger i = reuseRange.location; i < reuseRange.location + reuseRange.length; i++) {
        ANAsyncImageView * imageView = [imageViews objectAtIndex:i];
        [imageView setFrame:[self frameForPageIndex:(firstIndex + i)]];
        [imageView loadImageURL:[imageURLs objectAtIndex:(firstIndex + i)]];
    }
}

- (void)doneSlideshow:(id)sender {
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:initialBarStyle];
    [[UIApplication sharedApplication] setStatusBarHidden:initialBarHidden];
}

- (void)dealloc {
    [imageURLs release];
    [imageViews release];
    [scrollView release];
    [super dealloc];
}

#pragma mark - ScrollView -

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = [scrollView contentOffset];
    int pageIndex = (int)round(offset.x / scrollView.frame.size.width);
    if (pageIndex != currentPage) {
        currentPage = pageIndex;
        [self loadCachesAroundCurrentPage];
    }
}

- (void)scrollViewTapped:(UIScrollView *)aScrollView {
    // show or hide controls here
    if (!isShowingControls) {
        isShowingControls = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [scrollView setFrame:CGRectMake(0, 20, 320, 460)];
        [navigationBar setAlpha:0];
        [self.view addSubview:navigationBar];
        [UIView animateWithDuration:0.35 animations:^ {
            [navigationBar setAlpha:1];
        }];
    } else {
        isShowingControls = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [scrollView setFrame:CGRectMake(0, 0, 320, 480)];
        [UIView animateWithDuration:0.35 animations:^ {
            [navigationBar setAlpha:0];
        } completion:^(BOOL isDone) {
            if (isDone) {
                [navigationBar removeFromSuperview];
            }
        }];
    }
    CGSize size = scrollView.frame.size;
    [scrollView setContentSize:CGSizeMake([imageURLs count] * size.width, size.height)];
    for (NSUInteger i = 0; i < [imageViews count]; i++) {
        [[imageViews objectAtIndex:i] setFrame:[self frameForPageIndex:(firstImageIndex + i)]];
    }
}

- (CGRect)frameForPageIndex:(NSUInteger)pageIndex {
    return CGRectMake(pageIndex * scrollView.frame.size.width, 0,
                      scrollView.frame.size.width, scrollView.frame.size.height);
}

#pragma mark - Private -

- (NSUInteger)firstCacheIndexForIndex:(NSUInteger)index {
    NSUInteger firstIndex = 0;
    if (currentPage > 2) {
        firstIndex = currentPage - 2;
    }
    
    if (firstIndex + 5 > [imageURLs count] && firstIndex > 0) {
        NSUInteger overflow = (firstIndex + 5) - [imageURLs count];
        if (firstIndex >= overflow) {
            firstIndex -= overflow;
        } else {
            firstIndex = 0;
        }
    }
    return firstIndex;
}

@end
