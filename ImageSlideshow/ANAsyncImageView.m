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
- (void)loadComplete:(id)anImage;

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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextClearRect(UIGraphicsGetCurrentContext(), self.bounds);
    CGFloat scale = self.bounds.size.width / image.size.width;
    CGFloat height = image.size.height * scale;
    [image drawInRect:CGRectMake(0, self.bounds.size.height - height, self.bounds.size.width, height)];
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
#if !__has_feature(objc_arc)
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#else
    @autoreleasepool {
#endif
        // simulate a lag...
        // [NSThread sleepForTimeInterval:1];
        NSData * imageData = [NSData dataWithContentsOfURL:url];
#if !__has_feature(objc_arc)
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)imageData);
#else
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)imageData);
#endif
        CGImageRef loaded = NULL;
        if ([[url pathExtension] caseInsensitiveCompare:@"png"] == NSOrderedSame) {
            loaded = CGImageCreateWithPNGDataProvider(provider, NULL, false, kCGRenderingIntentDefault);
        } else {
            loaded = CGImageCreateWithJPEGDataProvider(provider, NULL, false, kCGRenderingIntentDefault);
        }
        CGDataProviderRelease(provider);
        
        // TODO: try creating a bitmap context here and drawing the image
        // as to flush any caches or whatever may be causing the ImageIO
        // error in the console.
        
        if ([[NSThread currentThread] isCancelled]) {
#if !__has_feature(objc_arc)
            [pool drain];
#endif
            CGImageRelease(loaded);
            return;
        }
#if __has_feature(objc_arc)
        id imageObj = (__bridge id)loaded;
#else
        id imageObj = (id)loaded;        
#endif
        [self performSelectorOnMainThread:@selector(loadComplete:) withObject:imageObj waitUntilDone:NO];
        CGImageRelease(loaded);
#if __has_feature(objc_arc)
    }
#else
    [pool drain];
#endif
}

- (void)loadComplete:(id)anImage {
#if __has_feature(objc_arc)
    CGImageRef loaded = (__bridge CGImageRef)anImage;
#else
    CGImageRef loaded = (CGImageRef)anImage;
#endif
    [self setImage:[UIImage imageWithCGImage:loaded]];
    if (anImage) {
        [activityIndicator stopAnimating];
    }
#if !__has_feature(objc_arc)
    [backgroundThread release];
#endif
    backgroundThread = nil;
}

@end
