//
//  CCouchDBServer.h
//  CouchTest
//
//  Created by Jonathan Wight on 02/16/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CouchDBClientTypes.h"

@class CCouchDBSession;
@class CCouchDBDatabase;
@class CURLOperation;

@interface CCouchDBServer : NSObject {
	CCouchDBSession *session;
	NSURL *URL;
	NSMutableDictionary *databasesByName;
}

@property (readonly, retain) CCouchDBSession *session;
@property (readonly, retain) NSURL *URL;
@property (readwrite, retain) NSURLCredential *URLCredential;
@property (readonly, retain) NSSet *databases;

- (id)init;
- (id)initWithSession:(CCouchDBSession *)inSession URL:(NSURL *)inURL;

- (CCouchDBDatabase *)databaseNamed:(NSString *)inName;

- (NSMutableURLRequest *)requestWithURL:(NSURL *)inURL;

- (CURLOperation *)operationToCreateDatabaseNamed:(NSString *)inName withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToFetchDatabasesWithSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToFetchDatabaseNamed:(NSString *)inName withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
- (CURLOperation *)operationToDeleteDatabase:(CCouchDBDatabase *)inDatabase withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

- (CURLOperation *)operationToFetchSessionWithSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

@end
