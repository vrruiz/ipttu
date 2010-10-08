//
//  PostViewController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	UIBarButtonItem *buttonBack;
	UIBarButtonItem *buttonForward;
	UIBarButtonItem *buttonCancel;
	UIBarButtonItem *buttonRefresh;
	UIBarButtonItem *buttonAction;
	UIBarButtonItem *buttonActivity;
	UIActivityIndicatorView *activityView;
	
	UITextField *textAddress;
	NSString *urlAddress;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonBack;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonForward;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonCancel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonRefresh;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonAction;
@property (nonatomic, retain) IBOutlet UITextField *textAddress;

- (IBAction) webBack;
- (IBAction) webForward;
- (IBAction) webCancel;
- (IBAction) webRefresh;
- (IBAction) webOpenSafari;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url;

@end
