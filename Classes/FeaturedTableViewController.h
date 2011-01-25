//
//  FeaturedTableViewController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeaturedTableViewController : UITableViewController {
	NSMutableArray *posts;
	NSMutableDictionary *images;
	UITableViewCell *tvCell;
	NSString *feed;
	NSString *lastDate;
	UIActivityIndicatorView *activityView;
	UIBarButtonItem *buttonActivity;
	NSString *file;
	IBOutlet UINavigationController *navController;
	IBOutlet UITabBarController *tabController;
	IBOutlet UIBarButtonItem *buttonRefresh;
}


- (IBAction) refresh: (id)sender;
- (NSString*)md5HexDigest:(NSString*)input;

@property (nonatomic, retain) NSString *feed;
@property (nonatomic, retain) NSString *file;
@property (nonatomic, retain) IBOutlet UITabBarController *tabController;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonRefresh;
@property (nonatomic, retain) IBOutlet UITableViewCell *tvCell;;

@end
