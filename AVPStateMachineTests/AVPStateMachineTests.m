//
//  AVPStateMachineTests.m
//  TestOrg
//
//  Created by Alexey Patosin on 06/08/14.
//  Copyright (c) 2014 TestOrg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AVPStateMachine.h"
#import "AVPState.h"
#import "AVPTestState.h"

@interface AVPMockStateMachineDelegate : NSObject < AVPStateMachineDelegate >

@end

@interface AVPStateMachineTests : XCTestCase
@property (nonatomic, strong) AVPStateMachine *stateMachine;
@property (nonatomic, strong) AVPState *state;
@property (nonatomic, strong) AVPTransition *transition;
@property (nonatomic, strong) AVPMockStateMachineDelegate *stateMachineDelegate;
@end

@implementation AVPStateMachineTests

- (void)setUp {
    [super setUp];

    self.stateMachine = [[AVPStateMachine alloc] initWithName:@"state machine" delegate:nil];
    self.transition = [AVPTransition new];
    self.state = [[AVPState alloc] initWithName:@"asdf"];
    self.stateMachineDelegate = [[AVPMockStateMachineDelegate alloc] init];
    
}

- (void)tearDown {

    [super tearDown];
}

#pragma mark - test store inside state machine

- (void)testShouldAddState {

    AVPState *state = [[AVPState alloc] initWithName:@"state"];

    [self.stateMachine addState:state];

    XCTAssert([self.stateMachine.states containsObject:state]);

}

- (void)testShouldAddStates {

    AVPState *state0 = [[AVPState alloc] initWithName:@"state0"];
    AVPState *state1 = [[AVPState alloc] initWithName:@"state1"];
    NSArray *states = @[state0, state1];

    [self.stateMachine addStates:states];

    XCTAssert([self.stateMachine.states isEqualToSet:[NSSet setWithArray:states]]);
    
}

- (void)testStateMachineShouldStoreTransitionsDictionary {
    
    NSString *eventName = @"event name";
    
    AVPState *state0 = [[AVPState alloc] initWithName:@"state0"];
    AVPState *state1 = [[AVPState alloc] initWithName:@"state1"];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:state0 toState:state1];
    
    [self.stateMachine addTransition:transition eventName:eventName];
    
    NSDictionary *transitions = [self.stateMachine transitionsForState:state0];
    
    XCTAssert(transitions[eventName] == transition, @"state machine must store transition for state");
    
}

- (void)testStateMachineShouldStoreSeveralTransitionsForState {

    NSString *eventName1 = @"event name 1";
    NSString *eventName2 = @"event name 2";
    
    AVPState *state1 = [[AVPState alloc] initWithName:@"state1"];
    AVPState *state2 = [[AVPState alloc] initWithName:@"state2"];
    AVPState *state3 = [[AVPState alloc] initWithName:@"state3"];
    
    AVPTransition *transition1 = [[AVPTransition alloc] initWithFromState:state1 toState:state2];
    AVPTransition *transition2 = [[AVPTransition alloc] initWithFromState:state1 toState:state3];
    
    [self.stateMachine addTransition:transition1 eventName:eventName1];
    [self.stateMachine addTransition:transition2 eventName:eventName2];
    
    NSDictionary *transitions = [self.stateMachine transitionsForState:state1];
    
    BOOL transition1Found = (transitions[eventName1] == transition1);
    BOOL transition2Found = (transitions[eventName2] == transition2);
    
    XCTAssert(transition1Found && transition2Found, @"state machine must store several transitions for state");
    
}

- (void)testStateMachineShouldProvideTransitionByEventNameFromState {
    
    NSString *eventName1 = @"event name 1";
    
    AVPState *state1 = [[AVPState alloc] initWithName:@"state1"];
    AVPState *state2 = [[AVPState alloc] initWithName:@"state2"];
    
    AVPTransition *transition1 = [[AVPTransition alloc] initWithFromState:state1 toState:state2];
    
    [self.stateMachine addTransition:transition1 eventName:eventName1];
    
    XCTAssert([self.stateMachine transitionForState:state1 eventName:eventName1] == transition1, @"state machine must provide transition for state and event name");
    
}

- (void)testStateMachineShouldStoreTheName {
    
    NSString *name = @"state machine";
    
    AVPStateMachine *stateMachine = [[AVPStateMachine alloc] initWithName:name delegate:nil];
    
    XCTAssert([stateMachine.name isEqualToString:name], @"state machine must store its name");
    
}

- (void)testStateMachineShouldStoreDelegate {
    
    id < AVPStateMachineDelegate > delegate = OCMProtocolMock(@protocol(AVPStateMachineDelegate));
    
    AVPStateMachine *stateMachine = [[AVPStateMachine alloc] initWithName:nil delegate:delegate];
    
    XCTAssert(stateMachine.delegate == delegate, @"state machine must store its delegate");
    
}

#pragma mark - test validity

- (void)testStateMachineShouldStart_StartState {
    
    AVPTestSimpleState *startState = [[AVPTestSimpleState alloc] initWithName:@"current start state"];
    AVPTestHoldState *holdState = [[AVPTestHoldState alloc] initWithName:@"hold state"];
    
    [self.stateMachine setStartState:startState];
    [self.stateMachine addState:holdState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:startState toState:holdState];
    
    [self.stateMachine addTransition:transition eventName:@"event name"];
    
    id mockStateMachine = [OCMockObject partialMockForObject:startState];
    [((AVPState *)[mockStateMachine expect]) start];
    
    [self.stateMachine start];
    
    [mockStateMachine verify];
    
}

#pragma mark - test delegate for states

- (void)testStateMachineSetSelfAsDelegateForStartState {
    
    AVPState *startState = [[AVPState alloc] initWithName:@"current start state"];
    [self.stateMachine setStartState:startState];

    XCTAssert(self.stateMachine == startState.delegate, @"state machine must set self as a delegate for state");
    
}

- (void)testStateMachineSetSelfAsDelegateForEachState {
    
    AVPState *state = [[AVPState alloc] initWithName:@"state"];
    [self.stateMachine addState:state];
    
    XCTAssert(((AVPState *)[self.stateMachine.states anyObject]).delegate == self.stateMachine, @"state machine must set self as a delegate for each state");
    
}

#pragma mark - test current state

- (void)testStateMachineCurrentStateShouldBeStartStateWhenItStarts {
    
    AVPState *startState = [[AVPState alloc] initWithName:@"current start state"];
    
    [self.stateMachine setStartState:startState];

    [self.stateMachine start];
    
    XCTAssert([startState.name isEqualToString:[self.stateMachine currentState].name], @"state machine must provide actual current state - at start it is a start state");
    
}

#pragma mark - test transitions

- (void)testStateMachineShouldMakeATransitionBetweenStates {
    
    AVPTestSimpleStateWithEventResult *startState = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"current start state"];
    AVPTestHoldState *holdState = [[AVPTestHoldState alloc] initWithName:@"hold state"];
    
    [self.stateMachine setStartState:startState];
    [self.stateMachine addState:holdState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:startState toState:holdState];
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];

    [self.stateMachine start];
    
    XCTAssert([self.stateMachine currentState] == holdState, @"state machine must make a transition to the second state");
    
}

- (void)testStateMachineShouldMakeATransitionAccordingEventName {
    
    AVPTestSimpleStateWithEventResult *startState = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"current start state"];
    AVPTestHoldState *holdStateForResultNO = [[AVPTestHoldState alloc] initWithName:@"hold state1"];
    AVPTestHoldState *holdStateForResultYES = [[AVPTestHoldState alloc] initWithName:@"hold state2"];
    
    [self.stateMachine setStartState:startState];
    [self.stateMachine addState:holdStateForResultNO];
    [self.stateMachine addState:holdStateForResultYES];
    
    AVPTransition *transitionForResultNO = [[AVPTransition alloc] initWithFromState:startState toState:holdStateForResultNO];

    AVPTransition *transitionForResultYES = [[AVPTransition alloc] initWithFromState:startState toState:holdStateForResultYES];
    
    [self.stateMachine addTransition:transitionForResultYES eventName:kTestYESEventName];
    [self.stateMachine addTransition:transitionForResultNO eventName:@"no event name"];
    
    [self.stateMachine start];
    
    XCTAssert([self.stateMachine currentState] == holdStateForResultYES, @"state machine must make a transition to the second state");
    
}

#pragma mark - test final states

- (void)testStateMachineShouldCallSuccessFinalStateAtTheEnd {
    
    AVPTestSimpleStateWithEventResult *startState = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"current start state"];
    AVPFinalState *successFinalState = [[AVPFinalState alloc] initWithName:@"final state"];
    
    [self.stateMachine setStartState:startState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:startState toState:successFinalState];
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    
    self.stateMachine.successFinalState = successFinalState;

    [self.stateMachine setDelegate:self.stateMachineDelegate];
    
    id mockDelegate = OCMPartialMock(self.stateMachineDelegate);
    
    [[mockDelegate expect] stateMachineCompletedWithSuccessState:[OCMArg any]];
    
    [self.stateMachine start];
    
    [mockDelegate verify];

}

- (void)testStateMachineShouldCallFailureFinalStateAtTheEndIfErrorHappened {
    
    AVPTestSimpleFailureState *failState = [[AVPTestSimpleFailureState alloc] initWithName:@"failure state"];
    AVPFinalState *failureFinalState = [[AVPFinalState alloc] initWithName:@"final state"];

    [self.stateMachine setStartState:failState];
    
    self.stateMachine.failureFinalState = failureFinalState;
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:failState toState:failureFinalState];
    [self.stateMachine addTransition:transition eventName:kTestSimpleFailureEventName];

    [self.stateMachine setDelegate:self.stateMachineDelegate];
    
    id mockDelegate = OCMPartialMock(self.stateMachineDelegate);
    
    [[mockDelegate expect] stateMachineCompletedWithFailureState:[OCMArg any]];
    
    [self.stateMachine start];
    
    [mockDelegate verify];
    
}

- (void)testStateMachineShouldCallCancelFinalStateAtTheEndIfWasCancelled {
    
    AVPTestSimpleCancelState *cancelState = [[AVPTestSimpleCancelState alloc] initWithName:@"cancel state"];
    AVPFinalState *cancelFinalState = [[AVPFinalState alloc] initWithName:@"final state"];
    
    [self.stateMachine setStartState:cancelState];
    
    self.stateMachine.cancelFinalState = cancelFinalState;
    
    [self.stateMachine setDelegate:self.stateMachineDelegate];
    
    id mockDelegate = OCMPartialMock(self.stateMachineDelegate);
    
    [[mockDelegate expect] stateMachineCompletedWithCancelState:[OCMArg any]];
    
    [self.stateMachine start];
    
    [mockDelegate verify];
    
}

- (void)testStateMachineSetSelfDelegateForSuccessFinalState {
    
    AVPFinalState *finalState = [[AVPFinalState alloc] initWithName:@"final state"];
    self.stateMachine.successFinalState = finalState;
    
    XCTAssert(finalState.delegate == self.stateMachine, @"state machine must set self as delegate for successFinalState");
    
}

- (void)testStateMachineSetSelfDelegateForFailureFinalState {
    
    AVPFinalState *finalState = [[AVPFinalState alloc] initWithName:@"final state"];
    self.stateMachine.failureFinalState = finalState;
    
    XCTAssert(finalState.delegate == self.stateMachine, @"state machine must set self as delegate for failureFinalState");
    
}

- (void)testStateMachineSetSelfDelegateForCancelFinalState {

    AVPFinalState *finalState = [[AVPFinalState alloc] initWithName:@"final state"];
    self.stateMachine.cancelFinalState = finalState;

    XCTAssert(finalState.delegate == self.stateMachine, @"state machine must set self as delegate for cancelFinalState");
    
}

#pragma mark - success/failure/cancel blocks for state

- (void)testStateMachineShouldCallSuccessBlockOfStateWhenSuccessfullyCompleted {
    
    AVPTestSimpleStateWithEventResult *fromState = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"from state"];
    AVPTestHoldState *toState = [[AVPTestHoldState alloc] initWithName:@"to state"];
    
    [self.stateMachine setStartState:fromState];
    [self.stateMachine addState:toState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:fromState toState:toState];
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    
    
}

#pragma mark - enter/leave calls tests

- (void)testStateMachineShouldCallwillEnterStateBlockForStartState {
    
    AVPTestSimpleStateWithEventResult *fromState = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"from state"];
    AVPTestHoldState *toState = [[AVPTestHoldState alloc] initWithName:@"to state"];
    
    [self.stateMachine setStartState:fromState];
    [self.stateMachine addState:toState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:fromState toState:toState];
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    
    __block int a = 0;
    
    [fromState setCompletionBlock:^(AVPState *state){
        
        a++;
        
    } stateLifeCycle:AVPStateLifeCycleWillEnter];
    
    BOOL aNotChangedBeforeStart = (a == 0);
    
    [self.stateMachine start];
    
    XCTAssert(aNotChangedBeforeStart && (a == 1), @"must be called willEnterStateBlock for start state");

}

- (void)testStateMachineShouldCallEnterLeaveMethodsInProperOrder {
    
    AVPTestSimpleStateWithEventResult *state0 = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"state 0"];
    AVPTestSimpleStateWithEventResult *state1 = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"state 1"];
    AVPTestHoldState *state2 = [[AVPTestHoldState alloc] initWithName:@"state 2"];
    
    [self.stateMachine setStartState:state0];
    [self.stateMachine addState:state1];
    [self.stateMachine addState:state2];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:state0 toState:state1];
    AVPTransition *transition2 = [[AVPTransition alloc] initWithFromState:state1 toState:state2];
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    [self.stateMachine addTransition:transition2 eventName:kTestYESEventName];
    
    __block int a = 0;
    __block BOOL isCorrect = YES;
    
    [state1 setCompletionBlock:^(AVPState *state){
        
        isCorrect = isCorrect && (a == 0);
        a++;
        
    } stateLifeCycle:AVPStateLifeCycleWillLeave];

    [state2 setCompletionBlock:^(AVPState *state){
        
        isCorrect = isCorrect && (a == 1);
        a++;
        
    } stateLifeCycle:AVPStateLifeCycleWillEnter];

    [state1 setCompletionBlock:^(AVPState *state){
        
        isCorrect = isCorrect && (a == 2);
        a++;
        
    } stateLifeCycle:AVPStateLifeCycleDidLeave];

    [state2 setCompletionBlock:^(AVPState *state){
        
        isCorrect = isCorrect && (a == 3);
        a++;
        
    } stateLifeCycle:AVPStateLifeCycleDidEnter];


    [self.stateMachine start];
    
    XCTAssert(isCorrect, @"enter/leave methods must be called in order prev.willLeave, next.willEnter, prev.didLeave, next.didEnter");
    
}

#pragma mark - test cancellation

- (void)testStateMachineShouldMayCancelState {
 
    AVPTestSimpleStateWithEventResult *fromState = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"from state"];
    AVPTestHoldState *toState = [[AVPTestHoldState alloc] initWithName:@"to state"];
    
    [self.stateMachine setStartState:fromState];
    [self.stateMachine addState:toState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:fromState toState:toState];
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    
    [self.stateMachine start];

    [self.stateMachine cancel];
    
    XCTAssert(toState.isCancelled, @"state machine must cancel current state");
    
}

- (void)testStateMachineShouldCallCancelFinalStateWhenCancelledTaskCompleted {
    
    AVPTestSimpleStateWithEventResult *fromState = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"from state"];
    AVPTestHoldCancellableState *toState = [[AVPTestHoldCancellableState alloc] initWithName:@"to state"];
    AVPFinalState *cancelFinalState = [[AVPFinalState alloc] initWithName:@"final state"];
    
    [self.stateMachine setStartState:fromState];
    [self.stateMachine addState:toState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:fromState toState:toState];
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    
    self.stateMachine.cancelFinalState = cancelFinalState;
    
    [self.stateMachine setDelegate:self.stateMachineDelegate];
    
    id mockDelegate = OCMPartialMock(self.stateMachineDelegate);

    [[mockDelegate expect] stateMachineCompletedWithCancelState:[OCMArg any]];

    [self.stateMachine start];
    [self.stateMachine cancel];
    
    [mockDelegate verify];
    
}

#pragma mark - transfer objects

- (void)testStateMachineMustTransferObjectFromOneStateToTheNextWhenSwitching {
    
    AVPTestSimpleStateWithEventResult *state1 = [AVPTestSimpleStateWithEventResult stateWithName:@"state1"];
    AVPTestHoldState *state2 = [AVPTestHoldState stateWithName:@"state2"];
    
    AVPTransition *transition = [AVPTransition transitionWithFromState:state1 toState:state2];
    
    [self.stateMachine setStartState:state1];
    [self.stateMachine addState:state2];
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    
    NSString *string = @"object";
    
    state1.outputObject = string;
    
    [self.stateMachine start];
    
    XCTAssert(state2.inputObject, @"state machine must pass outputObject from one state to the next one during switching");
    
}

#pragma mark - running tests

- (void)testStateMachineMustProvideIsRunningValue {
    
    AVPTestHoldState *state = [AVPTestHoldState stateWithName:@"state"];
    
    BOOL isRunningBeforeStart = [self.stateMachine isRunning];
    
    [self.stateMachine setStartState:state];
    [self.stateMachine start];
    
    XCTAssert(isRunningBeforeStart == NO && [self.stateMachine isRunning], @"state machine must provide isRunning if current state is running, it must be false before start");
    
}

- (void)testStateMachineMustBeNotRunningWhenCompletingFinalState {
    
    AVPTestSimpleStateWithEventResult *startState = [[AVPTestSimpleStateWithEventResult alloc] initWithName:@"current start state"];
    AVPFinalState *successFinalState = [[AVPFinalState alloc] initWithName:@"final state"];
    
    [self.stateMachine setStartState:startState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:startState toState:successFinalState];
    
    self.stateMachine.successFinalState = successFinalState;
    
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    
    [self.stateMachine start];
    
    XCTAssert([self.stateMachine isRunning] == NO, @"state machine must not not running when completing the final state");
    
}

#pragma mark - performance tests (Xcode 6+ only)

- (void)testPerformanceForAddState {

    // to not measure creating and accessing elements, add them to array with access about O(1)
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0;i<1000;i++) {
        AVPTestSimpleState *state = [[AVPTestSimpleState alloc] initWithName:[NSString stringWithFormat:@"%i", i]];
        [array addObject:state];
    }
    
    [self measureBlock:^{
        
        for (AVPState *state in array) {
            
            [self.stateMachine addState:state];
            
        }
        
    }];
    
}

- (void)testPerformanceForAddFirstTransitionForState {
    
    NSUInteger count = 1000;
    
    // to not measure creating and accessing elements, add them to array with access about O(1)
    NSMutableArray *array = [NSMutableArray array];
    
    AVPState *prevState = nil;
    
    for (int i=0;i<count;i++) {
        AVPTestSimpleState *state = [[AVPTestSimpleState alloc] initWithName:[NSString stringWithFormat:@"%i", i]];
        [self.stateMachine addState:state];
        
        if (prevState != nil) {
            
            AVPTransition *transition = [[AVPTransition alloc] initWithFromState:prevState toState:state];
            [array addObject:transition];
            
        }
        
        prevState = state;
    }
    
    [self measureBlock:^{
        
        for (AVPTransition *transition in array) {
            
            [self.stateMachine addTransition:transition eventName:transition.fromState.name];
            
        }
        
    }];
    
}


- (void)testPerformanceForAddNotFirstTransitionForState {
    
    NSUInteger count = 1000;
    
    // to not measure creating and accessing elements, add them to array with access about O(1)
    NSMutableArray *array = [NSMutableArray array];

    AVPTestSimpleState *state0 = [[AVPTestSimpleState alloc] initWithName:@"state"];
    [self.stateMachine addState:state0];
    
    for (int i=0;i<count;i++) {
        
        AVPTestSimpleState *state = [[AVPTestSimpleState alloc] initWithName:[NSString stringWithFormat:@"%i", i]];
        
        AVPTransition *transition = [[AVPTransition alloc] initWithFromState:state0 toState:state];
        [array addObject:transition];
        
    }
    
    [self measureBlock:^{
        
        for (AVPTransition *transition in array) {
            
            [self.stateMachine addTransition:transition eventName:transition.toState.name];
            
        }
        
    }];
    
}


- (void)testPerformanceForPerformTransition {
    
    AVPFinalState *finalState = [[AVPFinalState alloc] initWithName:@"final state"];
    
    NSUInteger count = 10;
    
    AVPState *prevState = nil;
    
    for (int i=0;i<count;i++) {
        AVPTestSimpleStateWithEventResult *state = [[AVPTestSimpleStateWithEventResult alloc] initWithName:[NSString stringWithFormat:@"%i", i]];
        [self.stateMachine addState:state];
        
        if (prevState != nil) {
            
            AVPTransition *transition = [[AVPTransition alloc] initWithFromState:prevState toState:state];
            [self.stateMachine addTransition:transition eventName:kTestYESEventName];
            
        }
        else {
            
            [self.stateMachine setStartState:state];
            
        }
        
        prevState = state;
    }
    
    [self.stateMachine addState:finalState];
    [self.stateMachine setSuccessFinalState:finalState];
    
    AVPTransition *transition = [[AVPTransition alloc] initWithFromState:prevState toState:finalState];
    [self.stateMachine addTransition:transition eventName:kTestYESEventName];
    
    [self measureBlock:^{
        
        [self.stateMachine start];
        
    }];
    
}

- (void)testPerformanceStateMachineCreation {
    
    __block AVPStateMachine *stateMachine = nil;
    
    [self measureBlock:^{
       
        for (int i=0;i<1000;i++) {
        
            stateMachine = [[AVPStateMachine alloc] initWithName:@"name" delegate:self.stateMachineDelegate];
            
        }
        
    }];
    
}

@end

@implementation AVPMockStateMachineDelegate

- (void)stateMachineCompletedWithSuccessState:(AVPStateMachine *)stateMachine {

}

- (void)stateMachineCompletedWithFailureState:(AVPStateMachine *)stateMachine {

}

- (void)stateMachineCompletedWithCancelState:(AVPStateMachine *)stateMachine {

}

@end
