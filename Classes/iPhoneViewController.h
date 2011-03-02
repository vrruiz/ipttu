//
//  iPhoneViewController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 02/03/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeaturedNavController;

@interface iPhoneViewController : UIViewController {
	IBOutlet UITabBarController *rootController;
	IBOutlet FeaturedNavController *featuredNavController;
	IBOutlet FeaturedNavController *blogNavController;
	IBOutlet FeaturedNavController *podcastNavController;
}

@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet FeaturedNavController *featuredNavController;
@property (nonatomic, retain) IBOutlet FeaturedNavController *blogNavController;
@property (nonatomic, retain) IBOutlet FeaturedNavController *podcastNavController;

@end
