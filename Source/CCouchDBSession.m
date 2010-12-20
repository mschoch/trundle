//
//  CCouchDBSession.m
//  TouchMetricsTest
//
//  Created by Jonathan Wight on 08/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBSession.h"

#import "CCouchDBURLOperation.h"
#import "CFilteringJSONSerializer.h"
#import "NSDate_InternetDateExtensions.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializedData.h"

#import "NSData_Base64Extensions.h"

@implementation CCouchDBSession

@synthesize operationQueue;
@synthesize URLOperationClass;
@synthesize serializer;
@synthesize deserializer;

- (void)dealloc
	{
	[operationQueue cancelAllOperations];
	[operationQueue waitUntilAllOperationsAreFinished];
	[operationQueue release];
	operationQueue = NULL;
	//
	[serializer release];
	serializer = NULL;
	//
	[deserializer release];
	deserializer = NULL;
	//
	[super dealloc];
	}

#pragma mark -

- (NSOperationQueue *)operationQueue
	{
	if (operationQueue == NULL)
		{
		operationQueue = [[NSOperationQueue alloc] init];
		}
	return(operationQueue);
	}

- (Class)URLOperationClass
	{
	if (URLOperationClass == NULL)
		{
		return([CCouchDBURLOperation class]);
		}
	return(URLOperationClass);
	}

- (CJSONSerializer *)serializer
	{
	if (serializer == NULL) 
		{
		CFilteringJSONSerializer *theSerializer = [CFilteringJSONSerializer serializer];
		theSerializer.convertersByName = [NSDictionary dictionaryWithObjectsAndKeys:
			[[^(NSDate *inDate) { return((id)[inDate ISO8601String]); } copy] autorelease], @"date",
			[[^(CJSONSerializedData *inObject) { return((id)inObject.data); } copy] autorelease], @"JSONSerializedData",
			NULL];
		theSerializer.tests = [NSSet setWithObjects:
			[[^(id inObject) { return([inObject isKindOfClass:[NSDate class]] ? @"date" : NULL); } copy] autorelease],
			[[^(id inObject) { return([inObject isKindOfClass:[CJSONSerializedData class]] ? @"JSONSerializedData" : NULL); } copy] autorelease],
			NULL];
			
		serializer = [theSerializer retain];
		}
	return(serializer);
	}

- (CJSONDeserializer *)deserializer
	{
	if (deserializer == NULL) 
		{
		CJSONDeserializer *theDeserializer = [CJSONDeserializer deserializer];
		deserializer = [theDeserializer retain];
		}
	return(deserializer);
	}

#pragma mark -

- (NSMutableURLRequest *)requestWithURL:(NSURL *)inURL
	{
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:inURL];
	
//	NSString *theValue = @"username:password";
//	NSData *theData = [theValue dataUsingEncoding:NSUTF8StringEncoding];
//	theValue = [theData asBase64EncodedString:0];
//	theValue = [NSString stringWithFormat:@"Basic %@", theValue];
//	[theRequest setValue:theValue forHTTPHeaderField:@"Authorization"];
	
	return(theRequest);
	}

- (id)URLOperationWithRequest:(NSURLRequest *)inURLRequest;
    {
    return([[[[self URLOperationClass] alloc] initWithSession:self request:inURLRequest] autorelease]);
    }
    
@end
