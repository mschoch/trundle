//
//  CCouchDBViewRow.m
//  CouchpadAdministrator
//
//  Created by Marty Schoch on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCouchDBViewRow.h"


@implementation CCouchDBViewRow

@synthesize key;
@synthesize value;
@synthesize doc;

- (void)dealloc {
    [key release];
    key = NULL;
    [value release];
    value = NULL;
    [doc release];
    doc = NULL;
    [super dealloc];
}

- (NSString *)description
{
    return([NSString stringWithFormat:@"%@ (key:%@ value:%@ doc:%@ )", [super description], self.key, self.value, self.doc]);
}

@end
