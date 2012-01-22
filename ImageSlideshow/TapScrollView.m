//
//  TapScrollView.m
//  ImageSlideshow
//
//  Created by Alex Nichol on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TapScrollView.h"

@implementation TapScrollView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        if ([self.delegate respondsToSelector:@selector(scrollViewTapped:)]) {
            [(id)self.delegate performSelector:@selector(scrollViewTapped:) withObject:self];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

@end
