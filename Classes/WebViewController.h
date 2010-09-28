//
//  PostViewController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
	IBOutlet UIWebView *webView;
	NSString *url;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
