//
//  CCouchDBDatabase.m
//  CouchTest
//
//  Created by Jonathan Wight on 02/16/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBDatabase.h"

#import "CCouchDBSession.h"
#import "CCouchDBServer.h"
#import "CFilteringJSONSerializer.h"
#import "CouchDBClientConstants.h"
#import "CCouchDBDocument.h"
#import "CCouchDBURLOperation.h"
#import "NSURL_Extensions.h"
#import "CCouchDBChangeSet.h"
#import "CCouchDBDesignDocument.h"
#import "CCouchDBView.h"
#import "CCouchDBViewRow.h"

@interface CCouchDBDatabase ()
@property (readonly, retain) NSMutableDictionary *designDocuments;
@end

@implementation CCouchDBDatabase

@synthesize server;
@synthesize name;
@synthesize designDocuments;

- (id)initWithServer:(CCouchDBServer *)inServer name:(NSString *)inName
	{
	if ((self = [self init]) != NULL)
		{
		server = inServer;
		name = [inName copy];
		}
	return(self);
	}

- (void)dealloc
	{
	server = NULL;
	[name release];
	name = NULL;
	[designDocuments release];
	designDocuments = NULL;
	//
	[super dealloc];
	}
	
#pragma mark -

- (NSString *)description
	{
	return([NSString stringWithFormat:@"%@ (rc:%d, %@)", [super description], self.retainCount, self.name]);
	}

- (CCouchDBSession *)session
	{
	NSAssert(self.server.session != NULL, @"No session!");
	return(self.server.session);
	}

#pragma mark -

- (NSString *)encodedName
	{
	@synchronized(self)
		{
		if (encodedName == NULL)
			{
			encodedName = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.name, NULL, CFSTR("/"), kCFStringEncodingUTF8);
			}
		return([[encodedName retain] autorelease]);
		}
	}

- (NSURL *)URL
	{
	@synchronized(self)
		{
		if (URL == NULL)
			{
			URL = [[self.server.URL URLByAppendingPathComponent:self.encodedName] retain];
			}
		return([[URL retain] autorelease]);
		}
	}

#pragma mark -

- (CCouchDBDesignDocument *)designDocumentNamed:(NSString *)inName;
	{
	CCouchDBDesignDocument *theDesignDocument = [self.designDocuments objectForKey:inName];
	if (theDesignDocument == NULL)
		{
		theDesignDocument = [[[CCouchDBDesignDocument alloc] initWithDatabase:self identifier:inName] autorelease];
		[self.designDocuments setObject:theDesignDocument forKey:inName];
		}
	return(theDesignDocument);	
	}

- (CURLOperation *)operationToCreateDocument:(NSDictionary *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
	{
	NSMutableURLRequest *theRequest = [self.server requestWithURL:self.URL];
	theRequest.HTTPMethod = @"POST";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

	NSData *theData = [self.session.serializer serializeDictionary:inDocument error:NULL];
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:theData];

	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		if (theOperation.error)
			{
			if (inFailureHandler)
				inFailureHandler(theOperation.error);
			return;
			}

		if ([[inParameter objectForKey:@"ok"] boolValue] == NO)
			{
			NSError *theError = [NSError errorWithDomain:kCouchErrorDomain code:-3 userInfo:NULL];
			if (inFailureHandler)
				inFailureHandler(theError);
			return;
			}

		NSString *theIdentifier = [inParameter objectForKey:@"id"];
		NSString *theRevision = [inParameter objectForKey:@"rev"];

		CCouchDBDocument *theDocument = [[[CCouchDBDocument alloc] initWithDatabase:self identifier:theIdentifier revision:theRevision] autorelease];
		[theDocument populateWithJSON:inDocument];

		if (inSuccessHandler)
			inSuccessHandler(theDocument);
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

- (CURLOperation *)operationToCreateDocument:(NSDictionary *)inDocument identifier:(NSString *)inIdentifier successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
	NSURL *theURL = [[self.URL absoluteURL] URLByAppendingPathComponent:inIdentifier];
	NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
	theRequest.HTTPMethod = @"PUT";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

	NSData *theData = [self.session.serializer serializeDictionary:inDocument error:NULL];
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:theData];

	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		if ([[inParameter objectForKey:@"ok"] boolValue] == NO)
			{
			NSError *theError = [NSError errorWithDomain:kCouchErrorDomain code:-3 userInfo:NULL];
			if (inFailureHandler)
				inFailureHandler(theError);
			return;
			}

		NSString *theRevision = [inParameter objectForKey:@"rev"];

		CCouchDBDocument *theDocument = [[[CCouchDBDocument alloc] initWithDatabase:self identifier:inIdentifier revision:theRevision] autorelease];
		[theDocument populateWithJSON:inDocument];

		if (inSuccessHandler)
			inSuccessHandler(theDocument);
		};
	theOperation.failureHandler = inFailureHandler;
	return(theOperation);
	}

#pragma mark -

- (CURLOperation *)operationToFetchAllDocumentsWithOptions:(NSDictionary *)inOptions withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
	return([self operationToBulkFetchDocuments:NULL options:inOptions successHandler:inSuccessHandler failureHandler:inFailureHandler]);
	}

- (CURLOperation *)operationToFetchDocumentForIdentifier:(NSString *)inIdentifier options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
	NSURL *theURL = [self.URL URLByAppendingPathComponent:inIdentifier];
	NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
	theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		CCouchDBDocument *theDocument = [[[CCouchDBDocument alloc] initWithDatabase:self] autorelease];

		[theDocument populateWithJSON:inParameter];

		if (inSuccessHandler)
			inSuccessHandler(theDocument);
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

- (CURLOperation *)operationToFetchDocument:(CCouchDBDocument *)inDocument options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
	// TODO -- this only fetches the latest document (i.e. _rev is ignored). What if we don't want the latest document?
	NSURL *theURL = inDocument.URL;
	NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
	theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		[inDocument populateWithJSON:inParameter];

		if (inSuccessHandler)
			inSuccessHandler(inDocument);
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

#pragma mark -

- (CURLOperation *)operationToUpdateDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
	NSURL *theURL = inDocument.URL;
	NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
	theRequest.HTTPMethod = @"PUT";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
	NSData *theData = [self.session.serializer serializeDictionary:inDocument.content error:NULL];
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:theData];

	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
		[inDocument populateWithJSON:inParameter];

		if (inSuccessHandler)
			inSuccessHandler(inDocument);
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

- (CURLOperation *)operationToDeleteDocument:(CCouchDBDocument *)inDocument successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
		NSMutableString *urlString = [[NSMutableString alloc] init];
		[urlString appendString: [inDocument.URL absoluteString]];
		[urlString appendFormat:@"?rev=%@", inDocument.revision];

		NSURL *theURL = [NSURL URLWithString:urlString];

		[inDocument.URL URLByAppendingPathComponent:[NSString stringWithFormat:@"?rev=%@", inDocument.revision]];
		NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
		theRequest.HTTPMethod = @"DELETE";
		[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
		CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
		theOperation.successHandler = ^(id inParameter) {
			if (inSuccessHandler)
				inSuccessHandler(inDocument);
			};
		theOperation.failureHandler = inFailureHandler;

		return(theOperation);
	}

- (CURLOperation *)operationToFetchChanges:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
    {
    NSURL *theURL = [self.URL URLByAppendingPathComponent:@"_changes"];
	if (inOptions)
		{
		theURL = [NSURL URLWithRoot:theURL queryDictionary:inOptions];
		}
    NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
    theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

    CCouchDBURLOperation *theOperation = [[[CCouchDBURLOperation alloc] initWithSession:self.session request:theRequest] autorelease];
    theOperation.successHandler = ^(id inParameter) {
		CCouchDBChangeSet *theChangeSet = [[[CCouchDBChangeSet alloc] initWithDatabase:self JSON:inParameter] autorelease];

        if (inSuccessHandler)
            inSuccessHandler(theChangeSet);
        };
    theOperation.failureHandler = inFailureHandler;

    return(theOperation);
    }

- (CURLOperation *)operationToBulkCreateDocuments:(id)inDocuments successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
    {
    NSURL *theURL = [self.URL URLByAppendingPathComponent:@"_bulk_docs"];
    NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
    theRequest.HTTPMethod = @"POST";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

    NSDictionary *theBody = [NSDictionary dictionaryWithObjectsAndKeys:
        inDocuments, @"docs",
        NULL];

    NSData *theData = [self.session.serializer serializeDictionary:theBody error:NULL];
    [theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:theData];

    CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
    theOperation.successHandler = ^(id inParameter) {
        if (theOperation.error)
            {
            if (inFailureHandler)
                inFailureHandler(theOperation.error);
            return;
            }

//        if ([[inParameter objectForKey:@"ok"] boolValue] == NO)
//            {
//            NSError *theError = [NSError errorWithDomain:kCouchErrorDomain code:-3 userInfo:NULL];
//            if (inFailureHandler)
//                inFailureHandler(theError);
//            return;
//            }

        if (inSuccessHandler)
            inSuccessHandler(theOperation.JSON);
        };

    return(theOperation);
    }
	
- (CURLOperation *)operationToBulkFetchDocuments:(NSArray *)inDocuments options:(NSDictionary *)inOptions successHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
	{
	NSURL *theURL = [self.URL URLByAppendingPathComponent:@"_all_docs"];
	
	if (inOptions == NULL)
		{
		inOptions = [NSDictionary dictionaryWithObject:@"true" forKey:@"include_docs"];
		}
	
	if (inOptions.count > 0)
		{
		theURL = [NSURL URLWithRoot:theURL queryDictionary:inOptions];
		}

	NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];

	if (inDocuments.count == 0)
		{
		theRequest.HTTPMethod = @"GET";
		}
	else
		{
		theRequest.HTTPMethod = @"POST";
		
		NSDictionary *theBodyDictionary = [NSDictionary dictionaryWithObject:inDocuments forKey:@"keys"];
		NSError *theError = NULL;
		NSData *theData = [self.session.serializer serializeDictionary:theBodyDictionary error:&theError];
		if (theData == NULL)
			{
			if (inFailureHandler)
				{
				inFailureHandler(theError);
				}
			return(NULL);
			}
		[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Content-Type"];
		[theRequest setHTTPBody:theData];
		}
	
	CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
	theOperation.successHandler = ^(id inParameter) {
        CCouchDBView *theView = [[CCouchDBView alloc] init];
        [theView setTotalRows:[(NSNumber *)[inParameter objectForKey:@"total_rows"] intValue]];
        [theView setOffset:[(NSNumber *)[inParameter objectForKey:@"offset"] intValue]];        
		NSMutableArray *theViewRows = [NSMutableArray array];
		for (NSDictionary *theRow in [inParameter objectForKey:@"rows"])
			{
            CCouchDBViewRow *viewRow = [[[CCouchDBViewRow alloc] init] autorelease];
            id key = [theRow objectForKey:@"key"];
            if(key)
                {
                [viewRow setKey:key];
                }
            id value = [theRow objectForKey:@"value"];
            if(value) 
                {
                [viewRow setValue:value];
                }
                
			NSDictionary *doc = [theRow objectForKey:@"doc"];
			if (doc)
				{
				CCouchDBDocument *theDocument = [[[CCouchDBDocument alloc] initWithDatabase:self] autorelease];
				[theDocument populateWithJSON:doc];

				[viewRow setDoc:theDocument];
				}
			else
				{
				NSString *theIdentifier = [theRow objectForKey:@"id"];

				CCouchDBDocument *theDocument = [[[CCouchDBDocument alloc] initWithDatabase:self identifier:theIdentifier] autorelease];
				theDocument.revision = [theRow valueForKeyPath:@"value.rev"];

				[viewRow setDoc:theDocument];
				}
            [theViewRows addObject:viewRow];
			}

        [theView setRows:theViewRows];
		if (inSuccessHandler)
			inSuccessHandler(theView);
		};
	theOperation.failureHandler = inFailureHandler;

	return(theOperation);
	}

@end
