//
//  Async.m
//  Async-objc
//
//  Created by Li, Jinyu on 4/8/13.
//  Copyright (c) 2013 Li, Jinyu. All rights reserved.
//

#import "Async.h"

#define kMaxConcurrentOperationCount 10

@interface Async ()

@property (nonatomic, strong) NSOperationQueue *mainQueue;

@end

@implementation Async

- (id)init {
    self = [super init];
    if (self) {
        _mainQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)each:(NSArray *)items iterator:(callbackEach)iterator complete:(callbackWithError)complete {
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        if (!items || items.count == 0) {
            complete(nil);
            return;
        }
        
        callbackWithError __block completeOnce = complete;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSLog(@"start operations %@", queue);
        [queue setMaxConcurrentOperationCount:kMaxConcurrentOperationCount];
        NSInteger __block count = 0;
        for (id item in items) {
            NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                iterator(item, ^(NSError *error) {
                    if (error) {
                        completeOnce(error);
                        completeOnce = nil;
                    } else {
                        count++;
                        if (count >= items.count) {
                            completeOnce(nil);
                            completeOnce = nil;
                        }
                    }
                });
            }];
            
            [queue addOperation:op];
        }
        
        [queue waitUntilAllOperationsAreFinished];
        NSLog(@"all operations are down %@", queue);
    }];
    [_mainQueue addOperation:blockOp];
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
