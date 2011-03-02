//
//  NewsView.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 21/02/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//


#import "NewsView.h"

@implementation NewsView

#define PADDING 5.0

@synthesize delegate;
@synthesize mode;
@synthesize labelTitle;
@synthesize labelCreator;
@synthesize labelSummary;
@synthesize imageView;
@synthesize activityIndicatorView;
@synthesize title;
@synthesize creator;
@synthesize summary;
@synthesize url;
@synthesize image;

// Snippet: http://stackoverflow.com/questions/603907/uiimage-resize-then-crop
- (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
	// UIImage *sourceImage = self;
	UIImage *newImage = nil;        
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
	{
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) 
			scaleFactor = widthFactor; // scale to fit height
        else
			scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		}
        else 
			if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
			}
	}       
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil) 
        NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)_title creator:(NSString *)_creator summary:(NSString *)_summary url:(NSString *)_url image:(UIImage *)_image mode:(NewsViewMode)_mode {
	// Creates a news view (image, source, text, arranged with mode)
	
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.userInteractionEnabled = YES; // Detect touches

		// Set content
		mode = _mode;
		title = _title;
		creator = _creator;
		summary = _summary;
		url = _url;
		image = _image;
		
		// Origin
		long padding = PADDING; 
		long orig_x = 0;
		long orig_y = 0;
		
		// Create view
		UIView *newsView = [[UIView alloc] init];
		newsView.userInteractionEnabled = YES;
		
		// Set size
		CGRect rectNews = CGRectMake(orig_x, orig_y, frame.size.width, frame.size.height);
		newsView.frame = rectNews;
		newsView.backgroundColor = [UIColor clearColor];
		[self addSubview:newsView];
		
		// Create image
		if (mode == NewsViewModeImageUpBig || mode == NewsViewModeImageUpSmall) {
			long height;
			switch (mode) {
				case NewsViewModeImageUpBig:
					// Image big
					height = newsView.frame.size.height / 2;
					break;
				case NewsViewModeImageUpSmall:
					// Image small
					NSLog(@"Small");
					height = newsView.frame.size.height / 3;
					break;
			}
			// If image is not nil, the create the view
			CGRect rectImage = CGRectMake(orig_x, orig_y, newsView.frame.size.width, height);
			imageView = [[UIImageView alloc] initWithFrame:rectImage];
			imageView.frame = rectImage;
			if (image) {
				// Set image
				imageView.image = [self imageByScalingAndCroppingForSize:image targetSize:rectImage.size];
			} else {
				// Show activity indicator
				activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				[activityIndicatorView setCenter:CGPointMake(rectImage.size.width / 2.0, rectImage.size.height / 2.0)];
				[imageView addSubview:activityIndicatorView];
				[activityIndicatorView startAnimating];
			}
			// Add subview
			[newsView addSubview:imageView];
			orig_y = imageView.frame.origin.x + imageView.frame.size.height + padding;
			// [imageView release];
		}
		
		// Create title
		CGRect rectLabel = CGRectMake(orig_x, orig_y, newsView.frame.size.width, 80);
		labelTitle = [[UILabel alloc] initWithFrame:rectLabel];
		labelTitle.font = [UIFont fontWithName:@"Palatino-Bold" size:28.0];
		labelTitle.lineBreakMode = UILineBreakModeWordWrap;
		labelTitle.numberOfLines = 2;
		labelTitle.backgroundColor = [UIColor clearColor];
		labelTitle.text = title;
		// Calculate title size
		CGSize expectedLabelSize = [labelTitle.text sizeWithFont:labelTitle.font
											   constrainedToSize:labelTitle.frame.size
												   lineBreakMode:UILineBreakModeWordWrap];
		// Resize title
		CGRect newFrame = labelTitle.frame;
		newFrame.size.height = expectedLabelSize.height;
		labelTitle.frame = newFrame;
		labelTitle.numberOfLines = 0;
		[labelTitle sizeToFit];
		// Add subview
		[newsView addSubview:labelTitle];
		
		// Create source label
		orig_y = labelTitle.frame.origin.y + labelTitle.frame.size.height + padding;
		CGRect rectSource = CGRectMake(orig_x, orig_y, newsView.frame.size.width, 40);
		labelCreator = [[UILabel alloc] initWithFrame:rectSource];
		labelCreator.font = [UIFont fontWithName:@"Optima-Bold" size:16.0];
		labelCreator.lineBreakMode = UILineBreakModeWordWrap;
		labelCreator.numberOfLines = 0;
		labelCreator.backgroundColor = [UIColor clearColor];
		labelCreator.textColor = [UIColor blueColor];
		labelCreator.text = creator;
		// Calculate title size
		expectedLabelSize = [labelCreator.text sizeWithFont:labelCreator.font
										  constrainedToSize:labelCreator.frame.size
											  lineBreakMode:UILineBreakModeWordWrap];
		// Resize source
		newFrame = labelCreator.frame;
		newFrame.size.height = expectedLabelSize.height;
		labelCreator.frame = newFrame;
		labelCreator.numberOfLines = 0;
		[labelCreator sizeToFit];
		// Add subview
		[newsView addSubview:labelCreator];
		orig_y = labelCreator.frame.origin.y + labelCreator.frame.size.height + padding;
		
		// Create image view if image next to text
		CGFloat source_width = newsView.frame.size.width;
		// Image next to text
		if (mode == NewsViewModeImageDown) {
			// Create image view
			CGRect rectImage = CGRectMake(newsView.frame.size.width / 2 + padding * 2, orig_y, newsView.frame.size.width - (newsView.frame.size.width / 2 + padding * 2), newsView.frame.size.height - orig_y);
			imageView = [[UIImageView alloc] initWithFrame:rectImage];
			imageView.frame = rectImage;
			if (image) {
				// Set image
				imageView.image = [self imageByScalingAndCroppingForSize:image targetSize:rectImage.size];
			} else {
				// Show activity indicator
				activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				activityIndicatorView.hidesWhenStopped = YES;
				[activityIndicatorView setCenter:CGPointMake(rectImage.size.width / 2.0, rectImage.size.height / 2.0)];
				[imageView addSubview:activityIndicatorView];
				[activityIndicatorView startAnimating];
			}
			// Add subview
			[newsView addSubview:imageView];
			// [imageView release];
			
			source_width = newsView.frame.size.width / 2 - padding * 2;
		}
		
		// Create text
		CGRect rectText = CGRectMake(orig_x, orig_y, source_width, newsView.frame.size.height - orig_y);
		labelSummary = [[UILabel alloc] initWithFrame:rectText];
		labelSummary.font = [UIFont fontWithName:@"Times New Roman" size:16.0];
		labelSummary.lineBreakMode = UILineBreakModeTailTruncation;
		labelSummary.numberOfLines = 0;
		labelSummary.backgroundColor = [UIColor clearColor];
		labelSummary.text = summary;
		// Calculate text size
		expectedLabelSize = [labelSummary.text sizeWithFont:labelSummary.font
										  constrainedToSize:labelSummary.frame.size
										   lineBreakMode:UILineBreakModeTailTruncation];
		// Resize text
		newFrame = labelSummary.frame;
		newFrame.size.height = expectedLabelSize.height;
		labelSummary.frame = newFrame;
		labelSummary.numberOfLines = 0;
		// [labelText sizeToFit];
		// Add subview
		[newsView addSubview:labelSummary];
		
		[newsView release];
	}
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event  {
	// Action through NewsScrollView 
	if (delegate && [delegate respondsToSelector:@selector(newsViewDidTouch:)]) {
		// Alert (NewsController)
		[delegate newsViewDidTouch:self];
	}
}

- (void)setImage:(UIImage*)_image {
	// Sets the image (usually updates the image after it is downloaded)
	if (activityIndicatorView) {
		// Stops the activity indicator
		[activityIndicatorView stopAnimating];
	}
	if (_image) {
		image = _image;
		imageView.image = [self imageByScalingAndCroppingForSize:_image targetSize:imageView.frame.size];
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
}
*/

- (void)dealloc {
	[activityIndicatorView release];
	[imageView release];
	[labelCreator release];
	[labelSummary release];
	[labelTitle release];
	[title release];
	[creator release];
	[summary release];
	[image release];
	[url release];
    [super dealloc];
}


@end
