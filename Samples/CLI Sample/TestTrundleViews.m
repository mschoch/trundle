//
//  TestTrundleViews
//
//  Uses a CouchDB database at:  http://mschoch.couchone.com/trundle_view_test/
//  with a design document at: http://mschoch.couchone.com/trundle_view_test/_design/test
//  this design document contains views returning various combinations of output
//
//  Created by Marty Schoch on 6/19/11.
//  Copyright 2011 Marty Schoch.
//

#import <Foundation/Foundation.h>
#import "CCouchDBServer.h"
#import "CCouchDBDatabase.h"
#import "CCouchDBSession.h"
#import "CouchDBClientTypes.h"
#import "CURLOperation.h"
#import "CRunLoopHelper.h"
#import "CCouchDBDesignDocument.h"


int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    CRunLoopHelper *theRLH = [[[CRunLoopHelper alloc] init] autorelease];

    
    NSURL *url = [NSURL URLWithString:@"http://mschoch.couchone.com/"];
    CCouchDBServer *theServer = [[[CCouchDBServer alloc] initWithSession:NULL URL:url] autorelease];
    CCouchDBDatabase *theDatabase = [theServer databaseNamed:@"trundle_view_test"];
    
    // Test getting all docs to make sure that continues to work
        
    CouchDBSuccessHandler successHandler = ^(id inParameter) {
		NSLog(@"Success getting all docs! %@: %@", [inParameter class], inParameter);
	};
    
	CouchDBFailureHandler failureHandler = ^(NSError *error) {
		NSLog(@"Fail getting all docs! %@", error);
	}; 
    
   CURLOperation *allDocsOperation = [theDatabase operationToFetchAllDocumentsWithOptions:nil withSuccessHandler:successHandler failureHandler:failureHandler];
    
    [theRLH prepare];
    
    [theServer.session.operationQueue addOperation:allDocsOperation];
    
    //prepare list of test view names
    NSArray *viewNamesToTest = [[NSArray alloc] initWithObjects:@"null-key", @"string-key", @"array-key", @"object-key", @"null-value", @"string-value", @"array-value", @"object-value" , nil];
    
    CCouchDBDesignDocument *designDocument = [[CCouchDBDesignDocument alloc] initWithDatabase:theDatabase identifier:@"test"];

    //test all views, no options
    for(NSString *viewName in viewNamesToTest) {
        
        CouchDBSuccessHandler viewSuccessHandler = ^(id inParameter) {
            NSLog(@"Success getting view %@! %@: %@", viewName, [inParameter class], inParameter);
        };
        
        CouchDBFailureHandler viewFailureHandler = ^(NSError *error) {
            NSLog(@"Fail getting view %@! %@", viewName, error);
        };        
        
        CURLOperation *getViewOperation = [designDocument operationToFetchViewNamed:viewName options:nil withSuccessHandler:viewSuccessHandler failureHandler:viewFailureHandler];
        
        [theServer.session.operationQueue addOperation:getViewOperation];
        
    }
    
    //test all views, include_docs=true
    for(NSString *viewName in viewNamesToTest) {
        
        CouchDBSuccessHandler viewSuccessHandler = ^(id inParameter) {
            NSLog(@"Success getting view with include_docs %@! %@: %@", viewName, [inParameter class], inParameter);
        };
        
        CouchDBFailureHandler viewFailureHandler = ^(NSError *error) {
            NSLog(@"Fail getting view with include_docs %@! %@", viewName, error);
        };        
        
        
        NSDictionary *options = [NSDictionary dictionaryWithObject:@"true" forKey:@"include_docs"];
        CURLOperation *getViewOperation = [designDocument operationToFetchViewNamed:viewName options:options withSuccessHandler:viewSuccessHandler failureHandler:viewFailureHandler];
        
        [theServer.session.operationQueue addOperation:getViewOperation];
        
    }    
    
    //test a view that has reduce
    NSArray *viewsWithReduce = [[NSArray alloc] initWithObjects:@"reduce-stats", nil];    
    for(NSString *viewName in viewsWithReduce) {
        
        CouchDBSuccessHandler viewSuccessHandler = ^(id inParameter) {
            NSLog(@"Success getting view with reduce %@! %@: %@", viewName, [inParameter class], inParameter);
        };
        
        CouchDBFailureHandler viewFailureHandler = ^(NSError *error) {
            NSLog(@"Fail getting view with reduce %@! %@", viewName, error);
        };        
        
        
        CURLOperation *getViewOperation = [designDocument operationToFetchViewNamed:viewName options:nil withSuccessHandler:viewSuccessHandler failureHandler:viewFailureHandler];
        
        [theServer.session.operationQueue addOperation:getViewOperation];
        
    }     

    [theRLH run]; 

    [pool drain];
    return 0;
}

