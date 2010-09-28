//
//  ipttuAppDelegate.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright European Southern Observatory & Víctor R. Ruiz 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FeaturedNavController;

@interface ipttuAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *rootController;
	IBOutlet FeaturedNavController *featuredNavController;
	IBOutlet FeaturedNavController *blogNavController;
	IBOutlet FeaturedNavController *podcastNavController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet FeaturedNavController *featuredNavController;
@property (nonatomic, retain) IBOutlet FeaturedNavController *blogNavController;
@property (nonatomic, retain) IBOutlet FeaturedNavController *podcastNavController;

@end

