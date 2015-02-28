//
//  AVPTransitionTests.m
//  TestOrg
//
//  Created by Alexey Patosin on 06/08/14.
//  Copyright (c) 2014 TestOrg. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "AVPTransition.h"

@interface AVPTransitionTests : XCTestCase

@end

@implementation AVPTransitionTests

- (void)testTransitionShouldStoreFromState {
    
    AVPState *state = [[AVPState alloc] initWithName:nil];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:state toState:nil];
    
    XCTAssert(transition.fromState == state, @"transition must store fromState");

    
}

- (void)testTransitionShouldStoreToState {

    AVPState *state = [[AVPState alloc] initWithName:nil];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:nil toState:state];
    
    XCTAssert(transition.toState == state, @"transition must store fromState");
    
}

- (void)testTransitionShouldSupportClassMethod {
    
    AVPState *state0 = [[AVPState alloc] initWithName:nil];
    AVPState *state1 = [[AVPState alloc] initWithName:nil];

    AVPTransition *transition = [AVPTransition transitionWithFromState:state0 toState:state1];
    
    XCTAssert(transition.fromState == state0 && transition.toState == state1, @"transition must support class method transitionWithFromState:toState: using");

}

- (void)testPerformanceTransitionCreation {
    
    AVPState *state0 = [[AVPState alloc] initWithName:nil];
    AVPState *state1 = [[AVPState alloc] initWithName:nil];
    
    __block AVPTransition *transition = nil;
    
    [self measureBlock:^{
       
        for (int i=0;i<0;i++) {
        
            transition = [[AVPTransition alloc] initWithFromState:state0 toState:state1];
            
        }
        
    }];
    
}

@end
