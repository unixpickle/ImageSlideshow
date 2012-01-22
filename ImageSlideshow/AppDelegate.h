//
//  AppDelegate.h
//  ImageSlideshow
//
//  Created by Alex Nichol on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANResourceSlideshow.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    ANResourceSlideshow * slideshow;
    UIViewController * mainVC;
}

@property (strong, nonatomic) UIWindow * window;

@end
