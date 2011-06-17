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

@implementation CCouchDBSession

@synthesize operationQueue;
@synthesize URLOperationClass;
@synthesize serializer;
@synthesize deserializer;

- (void)dealloc
	{
	[operationQueue cancelAllOperations];
	[operationQueue waitUntilAllOperationsAreFinished];
	//
	//
	//
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
		CFilteringJSONSerializer *theSerializer = (id)[CFilteringJSONSerializer serializer];
		theSerializer.convertersByName = [NSDictionary dictionaryWithObjectsAndKeys:
			[^(NSDate *inDate) { return((id)[inDate ISO8601String]); } copy], @"date",
			[^(CJSONSerializedData *inObject) { return((id)inObject.data); } copy], @"JSONSerializedData",
			NULL];
		theSerializer.tests = [NSSet setWithObjects:
			[^(id inObject) { return([inObject isKindOfClass:[NSDate class]] ? @"date" : NULL); } copy],
			[^(id inObject) { return([inObject isKindOfClass:[CJSONSerializedData class]] ? @"JSONSerializedData" : NULL); } copy],
			NULL];
			
		serializer = theSerializer;
		}
	return(serializer);
	}

- (CJSONDeserializer *)deserializer
	{
	if (deserializer == NULL) 
		{
		CJSONDeserializer *theDeserializer = [CJSONDeserializer deserializer];
		deserializer = theDeserializer;
		}
	return(deserializer);
	}

#pragma mark -

- (NSMutableURLRequest *)requestWithURL:(NSURL *)inURL
	{
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:inURL];
	return(theRequest);
	}

- (id)URLOperationWithRequest:(NSURLRequest *)inURLRequest;
    {
    return([[[self URLOperationClass] alloc] initWithSession:self request:inURLRequest]);
    }
    
@end
