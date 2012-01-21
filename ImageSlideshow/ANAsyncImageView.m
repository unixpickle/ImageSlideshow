//
//  ANAsyncImageView.m
//  ImageSlideshow
//
//  Created by Alex Nichol on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANAsyncImageView.h"

@interface ANAsyncImageView (Private)

- (void)backgroundLoadThread:(NSURL *)url;
- (void)loadComplete:(UIImage *)anImage;

@end

@implementation ANAsyncImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor blackColor];
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [activityIndicator setHidesWhenStopped:YES];
    }
    return self;
}

- (void)loadImageURL:(NSURL *)aURL {
    if (backgroundThread) {
        [self cancelLoading];
    }

    backgroundThread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(backgroundLoadThread:)
                                                 object:aURL];
    [backgroundThread start];
    [activityIndicator startAnimating];
    [self setImage:nil];
}

- (void)cancelLoading {
    [activityIndicator startAnimating];
    [backgroundThread cancel];
#if !__has_feature(objc_arc)
    [backgroundThread release];
#endif
    backgroundThread = nil;
}

- (UIImage *)image {
#if __has_feature(objc_arc)
    return image;
#else
    return [[image retain] autorelease];
#endif
}

- (void)setImage:(UIImage *)anImage {
#if __has_feature(objc_arc)
    image = anImage;
#else
    [image autorelease];
    image = [anImage retain];
#endif
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextClearRect(UIGraphicsGetCurrentContext(), self.bounds);
    [image drawInRect:self.bounds];
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    [image release];
    [backgroundThread release];
    [activityIndicator release];
    [super dealloc];
}
#endif

#pragma mark - Threading -

- (void)backgroundLoadThread:(NSURL *)url {
    @autoreleasepool {
        // simulate a lag...
        [NSThread sleepForTimeInterval:1];
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        UIImage * theImage = [[UIImage alloc] initWithData:imageData];
        if ([[NSThread currentThread] isCancelled]) {
#if !__has_feature(objc_arc)
            [theImage release];
#endif
            return;
        }
        [self performSelectorOnMainThread:@selector(loadComplete:) withObject:theImage waitUntilDone:NO];
#if !__has_feature(objc_arc)
        [theImage release];
#endif
    }
}

- (void)loadComplete:(UIImage *)anImage {
    [self setImage:anImage];
    if (anImage) {
        [activityIndicator stopAnimating];
    }
#if !__has_feature(objc_arc)
    [backgroundThread release];
#endif
    backgroundThread = nil;
}

@end
