//
//  NSOperation_PLBlockExtensions.h
//  iPad Sample
//
//  Created by Jonathan Wight on 04/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperation (NSOperation_PLBlockExtensions)

- (void (^)(void))completionBlock;
- (void)setCompletionBlock:(void (^)(void))block;

@end
