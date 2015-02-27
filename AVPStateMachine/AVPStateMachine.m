// The MIT License (MIT)
//
// Copyright (c) 2014 Alexey Patosin http://alexey.patosin.ru
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AVPStateMachine.h"

@interface AVPStateMachine ()

@property (nonatomic, weak) AVPState *currentState;
@property (nonatomic, strong) NSMutableSet *mutableStates;
@property (nonatomic, strong) NSMutableDictionary *transitions;
@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation AVPStateMachine

- (instancetype)initWithName:(NSString *)name delegate:(id< AVPStateMachineDelegate >)delegate {
    self = [super init];
    if (self) {
        NSParameterAssert(name);
        
        _delegate = delegate;
        _name = name;
        _mutableStates = [NSMutableSet set];
        _transitions = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - States

- (void)setStartState:(AVPState *)state {
    _startState = state;
    
    [state setDelegate:self];
}

- (void)setSuccessFinalState:(AVPFinalState *)successFinalState {
    _successFinalState = successFinalState;
    successFinalState.delegate = self;
}

- (void)setFailureFinalState:(AVPFinalState *)failureFinalState {
    _failureFinalState = failureFinalState;
    failureFinalState.delegate = self;
}

- (void)setCancelFinalState:(AVPFinalState *)cancelFinalState {
    _cancelFinalState = cancelFinalState;
    cancelFinalState.delegate = self;
}

- (void)addState:(AVPState *)state {
    [self.mutableStates addObject:state];
    
    [state setDelegate:self];
}

- (void)addStates:(NSArray *)states {
    for (AVPState *state in states) {
        [self addState:state];
    }
}

- (NSSet *)states {
    return [NSSet setWithSet:self.mutableStates];
}

- (BOOL)isInState:(AVPState *)state {
    return [self.currentState isEqual:state];
}

- (BOOL)isInStateWithName:(NSString *)stateName {
    return [self.currentState.name isEqual:stateName];
}

#pragma mark - Transitions

- (void)addTransition:(AVPTransition *)transition eventName:(NSString *)eventName {
    AVPState *fromState = transition.fromState;
    
    NSParameterAssert(eventName);
    NSParameterAssert(fromState);
    NSParameterAssert(transition);
    NSAssert([self.mutableStates containsObject:fromState] || self.startState == fromState, @"transition must contain state for appending event or it can be start state");
        
    NSMutableDictionary *dict = self.transitions[fromState.name];
    
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
        self.transitions[fromState.name] = dict;
    }
    
    dict[eventName] = transition;
}

- (NSDictionary *)transitionsForState:(AVPState *)state {
    return self.transitions[state.name];
}

- (AVPTransition *)transitionForState:(AVPState *)state eventName:(NSString *)eventName {
    return [self transitionsForState:state][eventName];
}

- (void)switchStateByTransition:(AVPTransition *)transition {
    [transition invokeCompletionBlockForTransitionLifeCycle:AVPTransitionLifeCycleWillTransition];
    [self switchStateToState:transition.toState];
    [transition invokeCompletionBlockForTransitionLifeCycle:AVPTransitionLifeCycleDidTransition];
}

- (void)switchStateToState:(AVPState *)nextState {
    NSParameterAssert(nextState);
    
    AVPState *prevState = self.currentState;
    
    [prevState invokeCompletionBlockForStateLifeCycle:AVPStateLifeCycleWillLeave];
    [nextState invokeCompletionBlockForStateLifeCycle:AVPStateLifeCycleWillEnter];
    
    if (nextState != self.startState) {
        nextState.inputObject = self.currentState.outputObject;
    }
    
    self.currentState = nextState;
    
    [prevState invokeCompletionBlockForStateLifeCycle:AVPStateLifeCycleDidLeave];
    [nextState invokeCompletionBlockForStateLifeCycle:AVPStateLifeCycleDidEnter];
    
    [nextState start];
}

- (void)performTransitionFromState:(AVPState *)state eventName:(NSString *)eventName error:(NSError *)error {
    AVPTransition *transition = [self transitionForState:state eventName:eventName];

    NSAssert(transition, @"#state_machine '%@' cannot find any conditions to switch from state '%@' with eventName '%@'", self.name, state.name, eventName);
    
    [self switchStateByTransition:transition];
}

#pragma mark - Main Logic

- (void)start {
    if ([self isRunning]) {
        NSAssert([self isRunning], @"#state_machine attempt to start state machine when it is already running");
        return;
    }
    
    [self switchStateToState:self.startState];
}

- (void)cancel {
    [self.currentState cancel];
}

#pragma mark - Helper methods

- (BOOL)isRunning {
    return [self.currentState isRunning];
}

#pragma mark - AVPStateDelegate methods

- (void)stateStarted:(AVPState *)state {
    NSLog(@"#state_machine '%@' stateStarted: '%@'", self.name, state.name);
    // may be implemented by descendants
}

- (void)stateFinished:(AVPState *)state eventName:(NSString *)eventName error:(NSError *)error {
    NSLog(@"#state_machine '%@' stateFinished: '%@' eventName: '%@' error: '%@'", self.name, state.name, eventName, error);

    if (error != nil) {
        self.error = error;
    }

    if ([state isKindOfClass:[AVPFinalState class]]) {
        [self performDelegateMethodCompletedFinalState:(AVPFinalState *)state error:error];
        return;
    }
    
    [self performTransitionFromState:state eventName:eventName error:error];
}

- (void)stateCancelled:(AVPState *)state {
    NSLog(@"#state_machine '%@' stateCancelled: '%@'", self.name, state.name);
    
    [self switchStateToState:self.cancelFinalState];
}

#pragma mark - perform delegate methods

- (void)performDelegateMethodCompletedFinalState:(AVPFinalState *)state error:(NSError *)error {
    if (state == self.successFinalState) {
        [self.delegate stateMachineCompletedWithSuccessState:self];
    }
    if (state == self.failureFinalState) {
        [self.delegate stateMachineCompletedWithFailureState:self];
    }
    if (state == self.cancelFinalState) {
        [self.delegate stateMachineCompletedWithCancelState:self];
    }
}

#pragma mark - notification methods

//TODO:state machine may receive NSNotifications like kAVPStateMachineEventOccuredNotification with userInfo[kStateMachineEventNameKey]. it will try to find transition for the self.currentState with this event name. that feature may help to call notifications outside of the state machine to make transitions


@end

@implementation AVPStateMachine (Validation)

- (BOOL)isValidWithError:(NSError **)error {
    // check mandatory states
    BOOL result = (self.startState != nil &&
                   self.successFinalState != nil &&
                   self.failureFinalState != nil &&
                   self.cancelFinalState != nil);
    
    
    if (!result) {
        [self createError:error errorCode:kAVPStateMachineValidationErrorCode_MissedStates userInfo:nil];
        return NO;
    }
    
    
    // check unique names for states
    result = [self checkStatesWithEqualNames:error];
    
    if (!result) {
        return NO;
    }
    
    // visit the graph
    NSMutableSet *visitedStates = [NSMutableSet set];
    NSMutableSet *notVisitedStates = [self.states mutableCopy];

    // cancel final state has not direct reference, it is accessible from all states by delegate method stateCancelled:. So it should not be verified here
    [notVisitedStates addObject:self.startState];
    [notVisitedStates addObject:self.successFinalState];
    [notVisitedStates addObject:self.failureFinalState];
    
    result = [self visitGraphWithCurrentState:self.startState
                                          visitedStates:visitedStates
                                                  error:error];
    
    if (!result) {
        return NO;
    }
    
    // check not visited states
    [notVisitedStates minusSet:visitedStates];
    result = [notVisitedStates count] == 0;
    
    if (!result) {
        NSArray *notUsedStates = [notVisitedStates allObjects];
        
        [self createError:error
                errorCode:kAVPStateMachineValidationErrorCode_NotUsedStates
                 userInfo:@{kAVPStateMachineValidationErrorUserInfoNotUsedStatesKey:notUsedStates}];
        
        return NO;
    }

    return result;
}

- (BOOL)visitGraphWithCurrentState:(AVPState *)currentState
                     visitedStates:(NSMutableSet *)visitedStates
                             error:(NSError **)error {
    __block BOOL result = YES;
    
    if (currentState) {
        [visitedStates addObject:currentState];
        
        NSDictionary *transitions = [self transitionsForState:currentState];
        
        // only final state don't have any transitions
        if ([transitions count] == 0 &&
            [currentState isKindOfClass:[AVPFinalState class]] == NO) {
            [self createError:error
                    errorCode:kAVPStateMachineValidationErrorCode_FinishedNotAtFinalState
                     userInfo:@{kAVPStateMachineValidationErrorUserInfoStateKey: currentState}];
            
            return NO;
        }
        else {
            [transitions enumerateKeysAndObjectsUsingBlock:^(id key, AVPTransition *transition, BOOL *stop) {
                
                AVPState *state = transition.toState;
                
                result = result && [self visitGraphWithCurrentState:state
                                                      visitedStates:visitedStates
                                                              error:error];
            }];
        }
    }    
    
    return result;
}

- (BOOL)checkStatesWithEqualNames:(NSError **)error {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableSet *errorStates = [NSMutableSet set];
    
    for (AVPState *state in self.states) {
        [self checkStateDict:dict state:state errorStates:errorStates];
    }
    
    [self checkStateDict:dict state:self.startState errorStates:errorStates];
    [self checkStateDict:dict state:self.successFinalState errorStates:errorStates];
    [self checkStateDict:dict state:self.failureFinalState errorStates:errorStates];
    [self checkStateDict:dict state:self.cancelFinalState errorStates:errorStates];
    
    if (errorStates) {
        [self createError:error
                errorCode:kAVPStateMachineValidationErrorCode_StatesWithSameName
                 userInfo:@{kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey:errorStates}];
    }
    
    return [errorStates count] == 0;
}

- (void)checkStateDict:(NSMutableDictionary *)dict state:(AVPState *)state errorStates:(NSMutableSet *)errorStates {
    id obj = dict[state.name];
    
    if (obj == nil) {
        dict[state.name] = state;
    }
    else {
        [errorStates addObject:state];
        [errorStates addObject:obj];
    }
}

- (void)createError:(NSError **)error errorCode:(kAVPStateMachineValidationErrorCode)errorCode userInfo:(NSDictionary *)userInfo {
    if (error) {
        *error = [NSError errorWithDomain:kAVPStateMachineValidationErrorDomain
                                     code:errorCode
                                 userInfo:userInfo];
    }
}

@end