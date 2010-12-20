//
//  CCouchDBServer_CookieSecurityExtensions.m
//  AnythingBucket
//
//  Created by Jonathan Wight on 12/19/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBServer_CookieSecurityExtensions.h"

#import "CURLOperation.h"

@implementation CCouchDBServer (CCouchDBServer_CookieSecurityExtensions)

//HOST="http://127.0.0.1:5984"
//> curl -vX POST $HOST/_session -H 'application/x-www-form-urlencoded' -d 'username=anna&password=secret'

- (CURLOperation *)operationToLoginWithCookieCredentials:(NSDictionary *)inCredentials withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;
	{
	NSString *theUsername = [inCredentials objectForKey:@"username"];
	NSString *thePassword = [inCredentials objectForKey:@"password"];
	
	NSString *theBodyString = [NSString stringWithFormat:@"username=%@&password=%@", theUsername, thePassword];
	NSLog(@"%@", theBodyString);
	NSData *theBodyData = [theBodyString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *theURL = [self.URL URLByAppendingPathComponent:@"_session"];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
	theRequest.HTTPMethod = @"POST";
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:theBodyData];
	[theRequest setHTTPShouldHandleCookies:NO];

	CURLOperation *theOperation = [[[CURLOperation alloc] initWithRequest:theRequest] autorelease];
	theOperation.completionBlock = ^(void) {
		
	
		NSLog(@"COMPLETE: %d", [(NSHTTPURLResponse *)theOperation.response statusCode]);
		NSLog(@"COMPLETE: %@", [(NSHTTPURLResponse *)theOperation.response allHeaderFields]);
		};
	
	
	
	return(theOperation);
	}



@end
