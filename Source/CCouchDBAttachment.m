//
//  CCouchDBAttachment.m
//  CouchTest
//
//  Created by Jonathan Wight on 02/23/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBAttachment.h"

@implementation CCouchDBAttachment

@synthesize document;
@synthesize identifier;
@synthesize contentType;
@synthesize data;

- (id)initWithIdentifier:(NSString *)inIdentifier contentType:(NSString *)inContentType data:(NSData *)inData;
	{
	if ((self = [super init]) != NULL)
		{
		identifier = inIdentifier;
		contentType = inContentType;
		data = inData;
		}
	return(self);
	}


@end
