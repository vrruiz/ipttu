//
//  MREntitiesConverter.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 30/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntitiesConverter : NSObject {
	NSMutableString* resultString;
}

@property (nonatomic, retain) NSMutableString* resultString;

- (NSString*)convertEntiesInString:(NSString*)s;

@end