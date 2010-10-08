//
//  PostViewController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 01/09/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostViewController : UIViewController {
	UILabel *labelTitle;
	UILabel *labelDate;
	UILabel *labelCreator;
	UIImageView *imageView;
	UITextView *textView;
	UIButton *button;
	NSMutableDictionary *item;
	UIToolbar *bottomToolbar;
	UIBarButtonItem *buttonLink;
	UIBarButtonItem *buttonPlay;
	UIBarButtonItem *buttonAction;
}

@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet UILabel *labelDate;
@property (nonatomic, retain) IBOutlet UILabel *labelCreator;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonAction;
@property (nonatomic, retain) NSMutableDictionary *item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil item:(NSMutableDictionary *)_item;
- (IBAction) openSafari:(id)sender;
- (void) openBrowser;

@end
