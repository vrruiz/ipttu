//
//  ipttuAppDelegate.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright European Southern Observatory & Víctor R. Ruiz 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iPhoneViewController;
@class NewsController;

@interface ipttuAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	iPhoneViewController *iphoneViewController;
	NewsController *ipadViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) iPhoneViewController *iphoneViewController;
@property (nonatomic, retain) NewsController *ipadViewController;

@end

