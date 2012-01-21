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

@end

@implementation ANAsyncImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
    }
    return self;
}

- (void)loadImageURL:(NSURL *)aURL {
    
}

- (void)cancelLoading {
    
}

#pragma mark - Threading -

- (void)backgroundLoadThread:(NSURL *)url {
    
}

@end
