//
//  AVPTestState.m
//  TestOrg
//
//  Created by Alexey Patosin on 07/08/14.
//  Copyright (c) 2014 TestOrg. All rights reserved.
//

#import "AVPTestState.h"

@implementation AVPTestSimpleState

- (void)start {
    [super start];
    
    [self.delegate stateFinished:self eventName:nil error:nil];
}

@end

@implementation AVPTestHoldState

- (void)start {
    [super start];
    
    // just do nothing. hold!
}

@end

@implementation AVPTestSimpleFailureState

- (void)start {
    [super start];
    
    NSError *error = [[NSError alloc] initWithDomain:@"test" code:0 userInfo:nil];
    [self performDelegateMethodCompletedWithEventName:kTestSimpleFailureEventName error:error];
}

@end

@implementation AVPTestSimpleCancelState

- (void)start {
    [super start];
    
    [self cancel];
}

- (void)cancel {
    [super cancel];
    
    [self performDelegateMethodCancel];
    
}

@end

@implementation AVPTestHoldCancellableState

- (void)start {
    [super start];
}

- (void)cancel {
    [super cancel];
    
    [self performDelegateMethodCancel];
    
}

@end

@implementation AVPTestSimpleStateWithEventResult

- (void)start {
    [super start];
    
    [self performDelegateMethodCompletedWithEventName:kTestYESEventName error:nil];
}

@end

