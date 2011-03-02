//
//  NewsScrollView.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 23/02/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "NewsScrollView.h"


@implementation NewsScrollView

// Snippet: http://iphonedevelopertips.com/user-interface/detect-single-tap-in-uiscrollview.html
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// Passes the event to the super view (NewsController)
	if (!self.dragging) {
		[self.nextResponder touchesEnded:touches withEvent:event];
	}
	[super touchesEnded:touches withEvent:event];
}

@end
