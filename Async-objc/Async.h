//
//  Async.h
//  Async-objc
//
//  Created by Li, Jinyu on 4/8/13.
//  Copyright (c) 2013 Li, Jinyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^callbackWithError)(NSError *error);
typedef void (^callbackEach)(id item, callbackWithError callback);

@interface Async : NSObject

- (void)each:(NSArray *)items iterator:(callbackEach)iterator complete:(callbackWithError)complete;
- (void)eachSeries:(NSArray *)items iterator:(callbackEach)iterator complete:(callbackWithError)complete;

@end
