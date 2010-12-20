//
//  CCouchDBDocument.m
//  CouchTest
//
//  Created by Jonathan Wight on 02/16/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBDocument.h"

#import "CouchDBClientConstants.h"
#import "CCouchDBAttachment.h"
#import "CCouchDBDatabase.h"
#import "CCouchDBDocument.h"
#import "CCouchDBServer.h"
#import "CCouchDBSession.h"
#import "CCouchDBURLOperation.h"

@interface CCouchDBDocument ()
@property (readonly, nonatomic, retain) CCouchDBSession *session;
@end

@implementation CCouchDBDocument

@synthesize database;
@synthesize identifier;
@synthesize revision;
@dynamic encodedIdentifier;
@dynamic URL;
@synthesize content;

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
    if ([key isEqualToString:@"asJSONDictionary"])
        return([NSSet setWithObjects:@"identifier", @"revision", @"content", NULL]);
    else
        {
        return(NULL);
        }
    }

- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase;
    {
    if ((self = [self init]) != NULL)
        {
        database = inDatabase;
        }
    return(self);
    }

- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase identifier:(NSString *)inIdentifier
    {
    if ((self = [self initWithDatabase:inDatabase]) != NULL)
        {
        identifier = [inIdentifier copy];
        }
    return(self);
    }

- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase identifier:(NSString *)inIdentifier revision:(NSString *)inRevision;
    {
    if ((self = [self initWithDatabase:inDatabase identifier:inIdentifier]) != NULL)
        {
        revision = [inRevision copy];
        }
    return(self);
    }

- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase JSON:(id)inJSON;
{
if ((self = [self initWithDatabase:inDatabase]) != NULL)
	{
	[self populateWithJSON:inJSON];
	}
return(self);
}

- (void)dealloc
    {
    database = NULL;
    [identifier release];
    identifier = NULL;
    [revision release];
    revision = NULL;
    [content release];
    content = NULL;
    //
    [super dealloc];
    }

#pragma mark -

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (id:%@ rev:%@ %@)", [super description], self.identifier, self.revision, self.content]);
    }

#pragma mark -

- (NSString *)identifier
    {
    @synchronized(self)
        {
        if (identifier == NULL && self.content != NULL)
            {
            return([self.content objectForKey:@"_id"]);
            }
        return(identifier);
        }
    }

- (void)setIdentifier:(NSString *)inIdentifier
    {
    @synchronized(self)
        {
        if (self.content == NULL)
            {
            if (identifier != inIdentifier)
                {
                [identifier release];
                identifier = [inIdentifier copy];
                }
            }
        else
            {
            if (identifier != NULL)
                {
                [identifier release];
                identifier = NULL;
                }

            NSMutableDictionary *theContent = [NSMutableDictionary dictionaryWithDictionary:self.content];
            [theContent setObject:inIdentifier forKey:@"_id"];
            self.content = theContent;
            }
        }
    }

- (NSString *)revision
    {
    @synchronized(self)
        {
        if (revision == NULL && self.content != NULL)
            {
            return([self.content objectForKey:@"_rev"]);
            }
        return(revision);
        }
    }

- (void)setRevision:(NSString *)inRevision
    {
    @synchronized(self)
        {
        if (self.content == NULL)
            {
            if (revision != inRevision)
                {
                [revision release];
                revision = [inRevision copy];
                }
            }
        else
            {
            if (revision != NULL)
                {
                [revision release];
                revision = NULL;
                }

            NSMutableDictionary *theContent = [NSMutableDictionary dictionaryWithDictionary:self.content];
            [theContent setObject:inRevision forKey:@"_rev"];
            self.content = theContent;
            }
        }
    }

- (NSString *)encodedIdentifier
    {
    return([(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.identifier, NULL, CFSTR("/"), kCFStringEncodingUTF8) autorelease]);
    }

- (NSURL *)URL
    {
    return([self.database.URL URLByAppendingPathComponent:self.encodedIdentifier]);
    }

#pragma mark -

- (CCouchDBSession *)session
    {
    return(self.database.server.session);
    }

#pragma mark -

- (void)populateWithJSON:(id)inDictionary
    {
    self.content = inDictionary;
    }

- (id)asJSON
    {
    if (self.content)
        {
        return(self.content);
        }
    else
        {
        return([NSDictionary dictionaryWithObjectsAndKeys:
            self.identifier, @"_id",
            self.revision, @"_rev",
            NULL]);
        }
    }

// TODO this is just a quick hack for attachments. Needs a lot more work.
- (void)addAttachment:(CCouchDBAttachment *)inAttachment
    {
    NSURL *theURL = [[self.URL absoluteURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@?rev=%@", inAttachment.identifier, self.revision]];

    NSMutableURLRequest *theRequest = [self.session requestWithURL:theURL];
    theRequest.HTTPMethod = @"PUT";
	[theRequest setValue:kContentTypeJSON forHTTPHeaderField:@"Accept"];
    [theRequest setValue:inAttachment.contentType forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:inAttachment.data];

    CCouchDBURLOperation *theOperation = [self.session URLOperationWithRequest:theRequest];
    theOperation.successHandler = ^(id inParameter) {
        if ([[inParameter objectForKey:@"ok"] boolValue] == NO)
            {
//            NSError *theError = [NSError errorWithDomain:kCouchErrorDomain code:-3 userInfo:NULL];
//            if (inFailureHandler)
//                inFailureHandler(theError);
            return;
            }

//        NSString *theIdentifier = [inParameter objectForKey:@"id"];
//        NSString *theRevision = [inParameter objectForKey:@"rev"];

//        if (inSuccessHandler)
//            inSuccessHandler(theDocument);
        };

//    return(theOperation);

    [self.session.operationQueue addOperation:theOperation];

    }


@end
