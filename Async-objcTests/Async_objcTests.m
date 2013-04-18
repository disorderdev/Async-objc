//
//  Async_objcTests.m
//  Async-objcTests
//
//  Created by Li, Jinyu on 4/8/13.
//  Copyright (c) 2013 Li, Jinyu. All rights reserved.
//

#import "Async_objcTests.h"

@implementation Async_objcTests

- (void)setUp
{
    [super setUp];
    _async = [[Async alloc] init];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
//    _async = nil;
    [super tearDown];
}

- (void)testEach
{
    BOOL __block completed = false;
    NSArray *items = @[@"1", @"2", @"3"];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:3];
    [_async each:items
        iterator:^(id item, callbackWithError callback) {
            NSNumber *num = [NSNumber numberWithInt:[item integerValue]];
            [result addObject:num];
            
            callback(nil);
        }
        complete:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STAssertNil(error, @"there should be no error");
                [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSNumber *num1 = (NSNumber *)obj1;
                    NSNumber *num2 = (NSNumber *)obj2;
                    if ([num1 integerValue] > [num2 integerValue]) {
                        return NSOrderedDescending;
                    } else if ([num1 integerValue] < [num2 integerValue]) {
                        return NSOrderedAscending;
                    }
                    return NSOrderedSame;
                }];
                
                NSInteger index = 1;
                for (NSNumber *num in result) {
                    STAssertEquals(index, [num integerValue], @"the value should be ordered");
                    index++;
                }
                completed = true;
            });
        }
     ];
    
    NSDate *until = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!completed && [until timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:until];
    }
}

- (void)testEachWithBigData
{
    BOOL __block completed = false;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:100];
    for (int i = 1; i < 100; ++i) {
        [items addObject:[NSString stringWithFormat:@"%d", i]];
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:100];
    [_async each:items
        iterator:^(id item, callbackWithError callback) {
            NSLog(@"======item %@", item);
            NSNumber *num = [NSNumber numberWithInt:[item integerValue]];
            NSLog(@"number %@", num);
            [result addObject:num];
            
            callback(nil);
        }
        complete:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STAssertNil(error, @"there should be no error");
                [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSNumber *num1 = (NSNumber *)obj1;
                    NSNumber *num2 = (NSNumber *)obj2;
                    if ([num1 integerValue] > [num2 integerValue]) {
                        return NSOrderedDescending;
                    } else if ([num1 integerValue] < [num2 integerValue]) {
                        return NSOrderedAscending;
                    }
                    return NSOrderedSame;
                }];
                
                NSInteger index = 1;
                for (NSNumber *num in result) {
                    STAssertEquals(index, [num integerValue], @"the value should be ordered");
                    index++;
                }
                completed = YES;
            });
        }
     ];
    
    NSDate *until = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!completed && [until timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:until];
    }
}

- (void)testEachWithError
{
    BOOL __block completed = false;
    NSArray *items = @[@"1", @"2", @"3", @"4", @"5"];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:3];
    [_async each:items
        iterator:^(id item, callbackWithError callback) {
            if ([item isEqual:@"5"]) {
                NSError *error = [[NSError alloc] init];
                callback(error);
            } else {
                NSNumber *num = [NSNumber numberWithInt:[item integerValue]];
                [result addObject:num];
                
                callback(nil);
            }
        }
        complete:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STAssertNotNil(error, @"there should be an error");
                completed = true;
            });
        }
     ];
    
    NSDate *until = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!completed && [until timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:until];
    }
}

@end
