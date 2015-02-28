//
//  AVPStateMachineValidationTests.m
//  TestOrg
//
//  Created by Alexey Patosin on 13/08/14.
//  Copyright (c) 2014 TestOrg. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AVPStateMachine.h"

@interface AVPStateMachineValidationTests : XCTestCase
@property (nonatomic, strong) AVPStateMachine *stateMachine;
@end

@implementation AVPStateMachineValidationTests

- (void)setUp {
    
    self.stateMachine = [[AVPStateMachine alloc] initWithName:@"test state machine" delegate:nil];
    
}

#pragma mark - helper methods

- (void)addStartState {
    
    AVPState *startState = [AVPState stateWithName:@"start state"];
    [self.stateMachine setStartState:startState];
    
}

- (void)addSuccessFinalState {
    
    AVPFinalState *successState = [AVPFinalState stateWithName:@"success state"];
    [self.stateMachine setSuccessFinalState:successState];
    
}

- (void)addFailureFinalState {
    
    AVPFinalState *failureState = [AVPFinalState stateWithName:@"failure state"];
    [self.stateMachine setFailureFinalState:failureState];
    
}

- (void)addCancelFinalState {
    
    AVPFinalState *cancelState = [AVPFinalState stateWithName:@"cancel state"];
    [self.stateMachine setCancelFinalState:cancelState];
    
}

- (void)addFinalStates {
 
    [self addSuccessFinalState];
    [self addFailureFinalState];
    [self addCancelFinalState];
    
}

- (void)addSuccessTransition {
 
    AVPTransition *successTransition = [AVPTransition transitionWithFromState:self.stateMachine.startState toState:self.stateMachine.successFinalState];
    [self.stateMachine addTransition:successTransition eventName:@"success"];
    
}

- (void)addFailureTransition {
    
    AVPTransition *failureTransition = [AVPTransition transitionWithFromState:self.stateMachine.startState toState:self.stateMachine.failureFinalState];
    [self.stateMachine addTransition:failureTransition eventName:@"failure"];
    
}

- (void)addCancelTransition {
    
    AVPTransition *cancelTransition = [AVPTransition transitionWithFromState:self.stateMachine.startState toState:self.stateMachine.cancelFinalState];
    [self.stateMachine addTransition:cancelTransition eventName:@"cancel"];
    
}

- (void)addStartAndFinalStates {
    
    [self addStartState];
    [self addFinalStates];
    
    [self addSuccessTransition];
    [self addFailureTransition];
    [self addCancelTransition];

}

#pragma mark - test missed properties

- (void)testStateMachineShouldBeInvalidWhenSuccessStateIsMissed {
    
    [self addStartState];

    [self addFailureFinalState];
    [self addCancelFinalState];
    
    [self addFailureTransition];
    [self addFailureFinalState];

    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine without success state must be invalid");
    
}

- (void)testStateMachineShouldBeInvalidWhenFailureStateIsMissed {
    
    [self addStartState];
    
    [self addSuccessFinalState];
    [self addCancelFinalState];
    
    [self addSuccessTransition];
    [self addCancelTransition];
    
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine without failure state must be invalid");
    
}

- (void)testStateMachineShouldBeInvalidWhenCancelStateIsMissed {
    
    [self addStartState];
    
    [self addSuccessFinalState];
    [self addFailureFinalState];
    
    [self addSuccessTransition];
    [self addFailureTransition];
    
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine without cancel state must be invalid");
    
}

- (void)testStateMachineShouldBeInvalidWhenStartStateIsMissed {
    
    [self addSuccessFinalState];
    [self addFailureFinalState];
    [self addCancelFinalState];
    
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine must be invalid when start state is missed");
}

#pragma mark - test visiting graph

- (void)testStateMachineShouldBeValidWhenStartStatesHasDirectTransitionsToFinalStates {
    
    [self addStartAndFinalStates];
    
    XCTAssert([self.stateMachine isValidWithError:nil], @"state machine with direct transitions from start to final states must be valid");
}

- (void)testStateMachineShouldBeInvalidWhenStartStateDoesNotHaveTransitions {

    [self addStartState];
    
    [self addSuccessFinalState];
    [self addFailureFinalState];
    [self addCancelFinalState];
 
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine without any transitions from start state must be invalid");
    
}

- (void)testStateMachineShouldBeInvalidWhenSuccessFinalStateNotVisited {
    
    [self addStartState];
    [self addFinalStates];
    
    [self addFailureTransition];
    [self addCancelTransition];
    
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine without visiting success state must be invalid");
    
}

- (void)testStateMachineShouldBeInvalidWhenFailureFinalStateNotVisited {
    
    [self addStartState];
    [self addFinalStates];
    
    [self addSuccessTransition];
    [self addCancelTransition];
    
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine without visiting failure state must be invalid");
    
}

- (void)testStateMachineShouldBeInvalidWhenRouteDoesNotFinishedAtFinalState {

    [self addStartAndFinalStates];
    
    AVPState *endState = [AVPState stateWithName:@"end state"];       // it doesn't have any transitions
    [self.stateMachine addState:endState];
    
    AVPTransition *transition = [AVPTransition transitionWithFromState:self.stateMachine.startState toState:endState];
    [self.stateMachine addTransition:transition eventName:@"transition"];
    
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine must be invalid when route finished at not AVPFinalState");
    
}

- (void)stateMachineMustBeValidWhenBetweenStartAndFinalStatesSeveralStates {
    
    [self addStartState];
    [self addFinalStates];
    
    [self addFailureTransition];
    [self addCancelTransition];
    
    AVPState *startState = self.stateMachine.startState;
    AVPFinalState *successState = self.stateMachine.successFinalState;
    
    AVPState *state1 = [AVPState stateWithName:@"state1"];
    AVPState *state2 = [AVPState stateWithName:@"state2"];
    AVPState *state3 = [AVPState stateWithName:@"state3"];
    AVPState *state4 = [AVPState stateWithName:@"state4"];
    AVPState *state5 = [AVPState stateWithName:@"state5"];
    AVPState *state6 = [AVPState stateWithName:@"state6"];
    
    AVPTransition *transition_0_1 = [AVPTransition transitionWithFromState:startState toState:state1];
    AVPTransition *transition_0_2 = [AVPTransition transitionWithFromState:startState toState:state2];
    AVPTransition *transition_1_3 = [AVPTransition transitionWithFromState:state1 toState:state3];
    AVPTransition *transition_2_4 = [AVPTransition transitionWithFromState:state2 toState:state4];
    AVPTransition *transition_3_5 = [AVPTransition transitionWithFromState:state3 toState:state5];
    AVPTransition *transition_3_6 = [AVPTransition transitionWithFromState:state3 toState:state6];
    AVPTransition *transition_4_success = [AVPTransition transitionWithFromState:state4 toState:successState];
    AVPTransition *transition_5_success = [AVPTransition transitionWithFromState:state5 toState:successState];
    AVPTransition *transition_6_success = [AVPTransition transitionWithFromState:state6 toState:successState];
    
    [self.stateMachine addTransition:transition_0_1 eventName:@"0_1"];
    [self.stateMachine addTransition:transition_0_2 eventName:@"0_2"];
    [self.stateMachine addTransition:transition_1_3 eventName:@"1_3"];
    [self.stateMachine addTransition:transition_2_4 eventName:@"2_4"];
    [self.stateMachine addTransition:transition_3_5 eventName:@"3_5"];
    [self.stateMachine addTransition:transition_3_6 eventName:@"3_6"];
    [self.stateMachine addTransition:transition_4_success eventName:@"4_success"];
    [self.stateMachine addTransition:transition_5_success eventName:@"5_success"];
    [self.stateMachine addTransition:transition_6_success eventName:@"6_success"];
    
    XCTAssert([self.stateMachine isValidWithError:nil], @"state machine with direct transitions from start to final states must be valid");
    
}

#pragma mark - test not used states and transitions

- (void)testStateMachineMustBeInvalidWhenExistNotUsedState {
    
    [self addStartAndFinalStates];
    
    AVPState *endState = [AVPState stateWithName:@"end state"];
    [self.stateMachine addState:endState];          // there's no any transitions for that state
    
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine must be invalid when route finished at not AVPFinalState");
    
}

- (void)testStateMachineMustBeInvalidWhenExistNotUsedReferencedStates {
    
    [self addStartAndFinalStates];
    
    // state1 does not have any input transitions
    AVPState *state1 = [AVPState stateWithName:@"state1"];
    AVPState *state2 = [AVPState stateWithName:@"state2"];
    
    [self.stateMachine addState:state1];
    [self.stateMachine addState:state2];
    
    AVPTransition *transition = [AVPTransition transitionWithFromState:state1 toState:state2];
    [self.stateMachine addTransition:transition eventName:@"transition1"];
    
    // actually never be used – state machine never come event to state 1
    AVPTransition *transition2 = [AVPTransition transitionWithFromState:state2 toState:self.stateMachine.successFinalState];
    [self.stateMachine addTransition:transition2 eventName:@"transition2"];
    
    XCTAssert([self.stateMachine isValidWithError:nil] == NO, @"state machine must be invalid when route finished at not AVPFinalState");
    
}

#pragma mark - NSError tests

- (void)testStateMachineMustProvideNSErrorWhenMissedProperties {

    NSError *error = nil;
    
    [self.stateMachine isValidWithError:&error];
    
    XCTAssert(error.code == kAVPStateMachineValidationErrorCode_MissedStates, @"state machine must provide NSError when missing properties");
    
}

- (void)testStateMachineMustProvideNSErrorForNotFinalStateWithoutAnyTransitions {
    
    NSError *error = nil;
    
    [self addStartState];
    [self addFinalStates];
    
    [self.stateMachine isValidWithError:&error];
    
    XCTAssert(error.code == kAVPStateMachineValidationErrorCode_FinishedNotAtFinalState &&
              error.userInfo[kAVPStateMachineValidationErrorUserInfoStateKey] == self.stateMachine.startState, @"state machine must provide at NSError not final state without any transitions");
}

- (void)testStateMachineMustProvideNSErrorWithNotReferencedStates {
        
    [self addStartAndFinalStates];
    
    // state1 does not have any input transitions
    AVPState *state1 = [AVPState stateWithName:@"state1"];
    AVPState *state2 = [AVPState stateWithName:@"state2"];
    
    [self.stateMachine addState:state1];
    [self.stateMachine addState:state2];
    
    AVPTransition *transition = [AVPTransition transitionWithFromState:state1 toState:state2];
    [self.stateMachine addTransition:transition eventName:@"transition1"];
    
    // actually never be used – state machine never come event to state 1
    AVPTransition *transition2 = [AVPTransition transitionWithFromState:state2 toState:self.stateMachine.successFinalState];
    [self.stateMachine addTransition:transition2 eventName:@"transition2"];
    
    NSError *error = nil;
    
    [self.stateMachine isValidWithError:&error];
    
    NSArray *array = error.userInfo[kAVPStateMachineValidationErrorUserInfoNotUsedStatesKey];
    
    XCTAssert(error.code == kAVPStateMachineValidationErrorCode_NotUsedStates &&
              [array containsObject:state1] &&
              [array containsObject:state2], @"state machine provide NSError with not used states");
    
}

- (void)testStateMachineMustProvideNSErrorWithNotEqualStateNames {

    [self addStartAndFinalStates];
 
    NSString *name = @"name";
    
    AVPState *state1 = [AVPState stateWithName:name];
    AVPState *state2 = [AVPState stateWithName:name];
    
    [self.stateMachine addState:state1];
    [self.stateMachine addState:state2];

    NSError *error = nil;
    
    [self.stateMachine isValidWithError:&error];
    
    NSArray *errorStates = error.userInfo[kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey];

    XCTAssert([errorStates containsObject:state1] && [errorStates containsObject:state2], @"state machine validation must provide states with same name at NSError");
    
}

- (void)testStateMachineMustProvideNSErrorWithStartStateWhichIsNotEqual {

    [self addStartAndFinalStates];
    
    AVPState *state1 = [AVPState stateWithName:self.stateMachine.startState.name];

    [self.stateMachine addState:state1];
    
    NSError *error = nil;
    
    [self.stateMachine isValidWithError:&error];
    
    NSArray *errorStates = error.userInfo[kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey];
    
    XCTAssert([errorStates containsObject:state1] && [errorStates containsObject:self.stateMachine.startState], @"state machine validation must provide start state and other states with the same name at NSError");
    
}

- (void)testStateMachineMustProvideNSErrorWithSuccessStateWhichIsNotEqual {
    
    [self addStartAndFinalStates];
    
    AVPState *state1 = [AVPState stateWithName:self.stateMachine.successFinalState.name];
    
    [self.stateMachine addState:state1];
    
    NSError *error = nil;
    
    [self.stateMachine isValidWithError:&error];
    
    NSArray *errorStates = error.userInfo[kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey];
    
    XCTAssert([errorStates containsObject:state1] && [errorStates containsObject:self.stateMachine.successFinalState], @"state machine validation must provide success state and other states with the same name at NSError");
    
}

- (void)testStateMachineMustProvideNSErrorWithFailureStateWhichIsNotEqual {
    
    [self addStartAndFinalStates];
    
    AVPState *state1 = [AVPState stateWithName:self.stateMachine.failureFinalState.name];
    
    [self.stateMachine addState:state1];
    
    NSError *error = nil;
    
    [self.stateMachine isValidWithError:&error];
    
    NSArray *errorStates = error.userInfo[kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey];
    
    XCTAssert([errorStates containsObject:state1] && [errorStates containsObject:self.stateMachine.failureFinalState], @"state machine validation must provide failure state and other states with the same name at NSError");
    
    
}

- (void)testStateMachineMustProvideNSErrorWithCancelStateWhichIsNotEqual {
 
    [self addStartAndFinalStates];
    
    AVPState *state1 = [AVPState stateWithName:self.stateMachine.cancelFinalState.name];
    
    [self.stateMachine addState:state1];
    
    NSError *error = nil;
    
    [self.stateMachine isValidWithError:&error];
    
    NSArray *errorStates = error.userInfo[kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey];
    
    XCTAssert([errorStates containsObject:state1] && [errorStates containsObject:self.stateMachine.cancelFinalState], @"state machine validation must provide cancel state and other states with the same name at NSError");
    
    
}

- (void)testStateMachineMustProvideNSErrorWithNotEqualCouplesOfStates {
    
    [self addStartAndFinalStates];
    
    NSString *name1 = @"name1";
    
    AVPState *state1 = [AVPState stateWithName:name1];
    AVPState *state2 = [AVPState stateWithName:name1];

    NSString *name2 = @"name2";
    
    AVPState *state3 = [AVPState stateWithName:name2];
    AVPState *state4 = [AVPState stateWithName:name2];
    
    
    [self.stateMachine addState:state1];
    [self.stateMachine addState:state2];
    [self.stateMachine addState:state3];
    [self.stateMachine addState:state4];
    
    NSError *error = nil;
    
    [self.stateMachine isValidWithError:&error];
    
    NSArray *errorStates = error.userInfo[kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey];
    
    XCTAssert([errorStates containsObject:state1] &&
              [errorStates containsObject:state2] &&
              [errorStates containsObject:state3] &&
              [errorStates containsObject:state4], @"state machine validation must provide states with same name at NSError");
    
}


@end
