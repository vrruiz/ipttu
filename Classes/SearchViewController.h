//
//  SearchViewController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 01/10/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate> {
	NSMutableArray *items;
	NSMutableString *lastSearch;
}

@end
