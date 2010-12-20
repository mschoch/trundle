//
//  CCouchDBServer_CookieSecurityExtensions.h
//  AnythingBucket
//
//  Created by Jonathan Wight on 12/19/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CCouchDBServer.h"

@interface CCouchDBServer (CCouchDBServer_CookieSecurityExtensions)

- (CURLOperation *)operationToLoginWithCookieCredentials:(NSDictionary *)inCredentials withSuccessHandler:(CouchDBSuccessHandler)inSuccessHandler failureHandler:(CouchDBFailureHandler)inFailureHandler;

@end
