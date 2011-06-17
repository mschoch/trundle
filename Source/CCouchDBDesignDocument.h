//
//  CCouchDBDesignDocument.h
//  AnythingBucket
//
//  Created by Jonathan Wight on 10/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CouchDBClientTypes.h"

@class CCouchDBDatabase;
@class CURLOperation;

@interface CCouchDBDesignDocument : NSObject {
    CCouchDBDatabase *__unsafe_unretained database;
    NSString *identifier;
}

@property (readonly, nonatomic, assign) CCouchDBDatabase *database;
@property (readonly, nonatomic, retain) NSString *identifier;
@property (readonly, nonatomic, retain) NSURL *URL;

- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase identifier:(NSString *)inIdentifier;

- (CURLOperation *)operationToFetchViewNamed:(NSString *)inName options:(NSDictionary *)inOptions withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

@end
