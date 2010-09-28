//
//  FeaturedNavController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeaturedTableViewController;

@interface FeaturedNavController : UINavigationController {
	IBOutlet FeaturedTableViewController *featuredTableViewController;
	NSString *feed;
}

@property (nonatomic, retain) FeaturedTableViewController *featuredTableViewController;
@property (nonatomic, retain) NSString *feed;

@end
