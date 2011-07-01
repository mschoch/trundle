//
//  CCouchDBDesignDocument.m
//  AnythingBucket
//
//  Created by Jonathan Wight on 10/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBDesignDocument.h"

#import "NSURL_Extensions.h"

#import "CCouchDBDatabase.h"
#import "CCouchDBDocument.h"
#import "CCouchDBServer.h"
#import "CCouchDBSession.h"
#import "CCouchDBURLOperation.h"
#import "CouchDBClientConstants.h"
#import "CCouchDBView.h"
#import "CCouchDBViewRow.h"

@interface CCouchDBDesignDocument ()
@property (readonly, nonatomic, retain) CCouchDBSession *session;
@end

#pragma mark -

@implementation CCouchDBDesignDocument

@synthesize database;
@synthesize identifier;

- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase identifier:(NSString *)inIdentifier
    {
    if ((self = [super init]) != NULL)
        {
        database = inDatabase;
        identifier = [inIdentifier retain];
        }
    return(self);
    }

- (void)dealloc
    {
    database = NULL;

    [identifier release];
    identifier = NULL;
    //
    [super dealloc];
    }

#pragma mark -

- (NSURL *)URL
    {
    return([self.database.URL URLByAppendingPathComponent:[NSString stringWithFormat:@"_design/%@", self.identifier]]);
    }

- (CCouchDBServer *)server
    {
    return(self.database.server);
    }

- (CCouchDBSession *)session
    {
    return(self.database.server.session);
    }

#pragma mark -

- (CURLOperation *)operationToFetchViewNamed:(NSString *)inName options:(NSDictionary *)inOptions withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler
	{
    NSURL *theURL = [self.URL URLByAppendingPathComponent:[NSString stringWithFormat:@"_view/%@", inName]];

    if (inOptions.count > 0)
        {
        theURL = [NSURL URLWithRoot:theURL queryDictionary:inOptions];
        }

    NSMutableURLRequest *theRequest = [self.server requestWithURL:theURL];
    theRequest.HTTPMethod = @"GET";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
    theOperation.successHandler = ^(id inParameter) {
        CCouchDBView *theView = [[[CCouchDBView alloc] init] autorelease];
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
				CCouchDBDocument *theDocument = [[[CCouchDBDocument alloc] initWithDatabase:database] autorelease];
				[theDocument populateWithJSON:doc];
                
				[viewRow setDoc:theDocument];
            }
			else
            {
				NSString *theIdentifier = [theRow objectForKey:@"id"];
                if(theIdentifier) {
                    CCouchDBDocument *theDocument = [[[CCouchDBDocument alloc] initWithDatabase:database identifier:theIdentifier] autorelease];
                    
                    [viewRow setDoc:theDocument];
                }
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
