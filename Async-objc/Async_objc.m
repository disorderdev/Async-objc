//
//  Async_objc.m
//  Async-objc
//
//  Created by Li, Jinyu on 4/8/13.
//  Copyright (c) 2013 Li, Jinyu. All rights reserved.
//

#import "Async_objc.h"


@interface Async_objc ()

@property (nonatomic, strong) NSOperationQueue *mainQueue;

@end

@implementation Async_objc

- (id)init {
    self = [super init];
    if (self) {
        _mainQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)each:(NSArray *)items iterator:(callbackEach)iterator complete:(callbackWithError)complete {
    [_mainQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        if (!items || items.count == 0) {
            complete(nil);
            return;
        }
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSInteger __block count = 0;
        for (id item in items) {
            NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                iterator(item, ^(NSError *error) {
                    if (error) {
                        complete(error);
                    } else {
                        count++;
                        if (count >= items.count) {
                            complete(nil);
                        }
                    }
                });
            }];
            
            [queue addOperation:op];
        }
        
        [queue waitUntilAllOperationsAreFinished];
    }]];
}

- (void)eachSeries:(NSArray *)items iterator:(callbackEach)iterator complete:(callbackWithError)complete {
    [_mainQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        if (!items || items.count == 0) {
            complete(nil);
            return;
        }
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        NSInteger __block count = 0;
        for (id item in items) {
            NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                iterator(item, ^(NSError *error) {
                    if (error) {
                        complete(error);
                    } else {
                        count++;
                        if (count >= items.count) {
                            complete(nil);
                        }
                    }
                });
            }];
            
            [queue addOperation:op];
        }
        
        [queue waitUntilAllOperationsAreFinished];
    }]];
}

@end
