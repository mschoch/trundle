//
//  CCouchDBDocument.h
//  CouchTest
//
//  Created by Jonathan Wight on 02/16/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCouchDBAttachment;
@class CCouchDBDatabase;

@interface CCouchDBDocument : NSObject /*<NSDiscardableContent>*/ {
	CCouchDBDatabase *__unsafe_unretained database;
	NSString *identifier;
	NSString *revision;
	NSDictionary *content;
}

@property (readonly, assign) CCouchDBDatabase *database;
@property (readwrite, copy) NSString *identifier;
@property (readwrite, copy) NSString *revision;
@property (readonly, copy) NSString *encodedIdentifier;
@property (readonly, copy) NSURL *URL;
@property (readwrite, copy) NSDictionary *content;

- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase;
- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase identifier:(NSString *)inIdentifier;
- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase identifier:(NSString *)inIdentifier revision:(NSString *)inRevision;
- (id)initWithDatabase:(CCouchDBDatabase *)inDatabase JSON:(id)inJSON;

- (void)populateWithJSON:(id)inDictionary;
- (id)asJSON;

- (void)addAttachment:(CCouchDBAttachment *)inAttachment;

@end
