//
//  AVPStateTests.m
//  TestOrg
//
//  Created by Alexey Patosin on 06/08/14.
//  Copyright (c) 2014 TestOrg. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "AVPState.h"
#import "AVPTestState.h"

@interface AVPMockStateDelegate : NSObject < AVPStateDelegate >
@end

@interface AVPStateTests : XCTestCase
@end

@implementation AVPStateTests

- (void)testStateShouldStoreName {
    
    NSString *name = @"name";
    
    AVPState *state = [[AVPState alloc] initWithName:name];
    
    XCTAssert([state.name isEqualToString:name], @"state must store name");
    
}

- (void)testStateShouldSupportClassMethod {

    NSString *name = @"name";

    AVPState *state = [AVPState stateWithName:name];
    
    XCTAssert([state.name isEqualToString:name], @"state must support using stateWithName: method");
    
}

#pragma mark - run/cancel tests

- (void)testStateShouldHaveIsRunningFalseAtBeforeState {
    
    AVPState *state = [[AVPState alloc] initWithName:nil];
    
    XCTAssertFalse([state isRunning], @"state must have isRunning == NO before start");
    
}


- (void)testStateShouldHaveIsRunningTrueAfterStart {
    
    AVPState *state = [[AVPState alloc] initWithName:nil];
    
    [state start];
    
    XCTAssert([state isRunning], @"state must have isRunning == YES after start");
    
}

- (void)testStateShouldHaveIsCancelledFalseBeforeCancel {

    AVPState *state = [[AVPState alloc] initWithName:nil];
    
    [state start];
    
    XCTAssertFalse([state isCancelled], @"state must have isCancelled == NO before cancel");

}

- (void)testStateShouldHaveIsCancelledTrueAfterCancel {
    
    AVPState *state = [[AVPState alloc] initWithName:nil];
    
    [state start];
    [state cancel];
    
    XCTAssert([state isCancelled], @"state must have isCancelled == YES after cancel");
    
}

- (void)testStateShouldBeNotRunningWhenCancellationIsCompleted {
    
    AVPTestSimpleCancelState *state = [[AVPTestSimpleCancelState alloc] initWithName:@"state"];
    
    [state start];
    [state cancel];
    
    XCTAssert(state.isRunning == NO, @"state must be not running after cancellation is completed");
    
}

- (void)testStateShouldBeNotRunningWhenCompletedSuccessfully {
    
    AVPTestSimpleStateWithEventResult *state = [AVPTestSimpleStateWithEventResult stateWithName:@"state"];
    
    [state start];
    
    XCTAssert([state isRunning] == NO, @"state must be not running when completing successfully");
    
}


- (void)testStateShouldBeNotRunningWhenCompletedWithError {
    
    AVPTestSimpleFailureState *state = [AVPTestSimpleFailureState stateWithName:@"state"];
    
    [state start];
    
    XCTAssert([state isRunning] == NO, @"state must be not running when completing with error");
    
}

#pragma mark - completion blocks tests

- (void)testStateShouldStoreWillEnterCompletionBlock {
    
    __block BOOL result = NO;
    AVPStateCompletionBlock completionBlock = ^(AVPState *state) {
        result = YES;
    };
    
    AVPState *state = [[AVPState alloc] initWithName:nil];
    [state setCompletionBlock:completionBlock stateLifeCycle:AVPStateLifeCycleWillEnter];
    
    [state invokeCompletionBlockForStateLifeCycle:AVPStateLifeCycleWillEnter];
    
    XCTAssert(result, @"state much store completionBlock for willEnter event");
    
}

- (void)testStateShouldStoreDidEnterCompletionBlock {
    
    __block BOOL result = NO;
    AVPStateCompletionBlock completionBlock = ^(AVPState *state) {
        result = YES;
    };
    
    AVPState *state = [[AVPState alloc] initWithName:nil];
    [state setCompletionBlock:completionBlock stateLifeCycle:AVPStateLifeCycleDidEnter];
    
    [state invokeCompletionBlockForStateLifeCycle:AVPStateLifeCycleDidEnter];
    
    XCTAssert(result, @"state much store completionBlock for didEnter event");
    
}

- (void)testStateShouldStoreWillLeaveCompletionBlock {
    
    __block BOOL result = NO;
    AVPStateCompletionBlock completionBlock = ^(AVPState *state) {
        result = YES;
    };
    
    AVPState *state = [[AVPState alloc] initWithName:nil];
    [state setCompletionBlock:completionBlock stateLifeCycle:AVPStateLifeCycleWillLeave];
    
    [state invokeCompletionBlockForStateLifeCycle:AVPStateLifeCycleWillLeave];

    XCTAssert(result, @"state much store completionBlock for willLeave event");
    
}

- (void)testStateShouldStoreDidLeaveCompletionBlock {
    
    __block BOOL result = NO;
    AVPStateCompletionBlock completionBlock = ^(AVPState *state) {
        result = YES;
    };
    
    AVPState *state = [[AVPState alloc] initWithName:nil];
    [state setCompletionBlock:completionBlock stateLifeCycle:AVPStateLifeCycleDidLeave];
    
    [state invokeCompletionBlockForStateLifeCycle:AVPStateLifeCycleDidLeave];

    XCTAssert(result, @"state much store completionBlock for didLeave event");
    
}

#pragma mark - test call delegate methods

- (void)testStateShouldCallDelegateMethodAtStart {
    
    AVPMockStateDelegate *stateDelegate = [AVPMockStateDelegate new];
    AVPState *state = [[AVPState alloc] initWithName:nil];
    state.delegate = stateDelegate;
    
    id mockDelegate = OCMPartialMock(stateDelegate);
    [[mockDelegate expect] stateStarted:[OCMArg any]];
    
    [state start];
    
    [mockDelegate verify];
    
}

- (void)testStateShouldCallDelegateMethodAtCompletedSuccessfully {
    
    AVPMockStateDelegate *stateDelegate = [AVPMockStateDelegate new];
    AVPTestSimpleState *state = [[AVPTestSimpleState alloc] initWithName:nil];
    state.delegate = stateDelegate;
    
    id mockDelegate = OCMPartialMock(stateDelegate);
    [[mockDelegate expect] stateFinished:state eventName:[OCMArg any] error:nil];
    
    [state start];
    
    [mockDelegate verify];
    
}

- (void)testStateShouldCallDelegateMethodAtCompletedFailure {
    
    AVPMockStateDelegate *stateDelegate = [AVPMockStateDelegate new];
    AVPTestSimpleFailureState *state = [[AVPTestSimpleFailureState alloc] initWithName:nil];
    state.delegate = stateDelegate;
    
    id mockDelegate = OCMPartialMock(stateDelegate);
    [[mockDelegate expect] stateFinished:state eventName:[OCMArg any] error:[OCMArg any]];
    
    [state start];
    
    [mockDelegate verify];
    
}

- (void)testStateShouldCallDelegateMethodAtCompletedCancelled {
    
    AVPMockStateDelegate *stateDelegate = [AVPMockStateDelegate new];
    AVPTestSimpleCancelState *state = [[AVPTestSimpleCancelState alloc] initWithName:nil];
    state.delegate = stateDelegate;
    
    id mockDelegate = OCMPartialMock(stateDelegate);
    [[mockDelegate expect] stateCancelled:[OCMArg any]];
    
    [state start];
    
    [mockDelegate verify];
    
}

- (void)testPerformanceStateCreation {
    
    __block AVPState *state = nil;
    
    [self measureBlock:^{
        
        for (int i=0;i<1000;i++) {
            
            state = [[AVPState alloc] initWithName:@"name"];
            
        }
        
    }];
    
}

@end

@implementation AVPMockStateDelegate

- (void)stateStarted:(AVPState *)state{}
- (void)stateFinished:(AVPState *)state eventName:(NSString *)eventName error:(NSError *)error{}
- (void)stateCancelled:(AVPState *)state{}

@end