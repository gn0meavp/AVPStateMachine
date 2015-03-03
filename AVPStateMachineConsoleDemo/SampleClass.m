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

#import "SampleClass.h"

#import "AVPTransition.h"
#import "AVPStateMachine.h"

#import "SampleStartState.h"
#import "SampleState1.h"
#import "SampleState2.h"
#import "SampleState3.h"
#import "SampleState4.h"
#import "SampleSuccessFinalState.h"
#import "SampleFailureFinalState.h"
#import "SampleCancelledFinalState.h"

@interface SampleClass () <AVPStateMachineDelegate>
@property (nonatomic, strong) AVPStateMachine *stateMachine;
@end

@implementation SampleClass

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupStateMachine];
    }
    return self;
}

- (void)setupStateMachine {
    
    _stateMachine = [[AVPStateMachine alloc] initWithName:@"Test state machine" delegate:self];

    ////////////////////////////////////////////
    
    // create start mandatory state
    SampleStartState *startState = [SampleStartState stateWithName:@"start state"];
    
    // create some sample states
    SampleState1 *doState = [SampleState1 stateWithName:@"Do state"];
    SampleState2 *reState = [SampleState2 stateWithName:@"Re state"];
    SampleState3 *miState = [SampleState3 stateWithName:@"Mi state"];
    SampleState4 *faState = [SampleState4 stateWithName:@"Fa state"];
    
    // create final mandatory states
    SampleSuccessFinalState *successFinalState = [SampleSuccessFinalState stateWithName:@"success"];
    SampleFailureFinalState *failureFinalState = [SampleFailureFinalState stateWithName:@"failure"];
    SampleCancelledFinalState *cancelFinalState = [SampleCancelledFinalState stateWithName:@"cancelled"];
    
    ////////////////////////////////////////////
    
    // set start state
    [_stateMachine setStartState:startState];
    
    // set final states
    [_stateMachine setSuccessFinalState:successFinalState];
    [_stateMachine setFailureFinalState:failureFinalState];
    [_stateMachine setCancelFinalState:cancelFinalState];
    
    // add sample states
    [_stateMachine addState:doState];
    [_stateMachine addState:reState];
    [_stateMachine addState:miState];
    [_stateMachine addState:faState];
    
    ////////////////////////////////////////////

    // transition from start state
    AVPTransition *transitionStart = [AVPTransition transitionWithFromState:startState toState:doState];
    
    // couple of transitions from doState
    AVPTransition *transitionDoRe = [AVPTransition transitionWithFromState:doState toState:reState];
    AVPTransition *transitionDoFa = [AVPTransition transitionWithFromState:doState toState:faState];
    
    // failure transitions from state which may fail
    AVPTransition *transitionDoFailed = [AVPTransition transitionWithFromState:doState toState:failureFinalState];
    AVPTransition *transitionFaFailed = [AVPTransition transitionWithFromState:faState toState:failureFinalState];
    
    // add other transitions
    AVPTransition *transitionReMi = [AVPTransition transitionWithFromState:reState toState:miState];
    AVPTransition *transitionMiFinal = [AVPTransition transitionWithFromState:miState toState:successFinalState];
    AVPTransition *transitionFaFinal = [AVPTransition transitionWithFromState:faState toState:successFinalState];
    
    [_stateMachine addTransition:transitionStart eventName:kSampleStartEventName];
    [_stateMachine addTransition:transitionDoRe eventName:kDoReEventName];
    [_stateMachine addTransition:transitionDoFa eventName:kDoFaEventName];
    [_stateMachine addTransition:transitionReMi eventName:kReMiEventName];
    [_stateMachine addTransition:transitionMiFinal eventName:kMiSuccessEventName];
    [_stateMachine addTransition:transitionFaFinal eventName:kFaSuccessEventName];
    [_stateMachine addTransition:transitionDoFailed eventName:kDoFailedEventName];
    [_stateMachine addTransition:transitionFaFailed eventName:kFaFailedEventName];

    [transitionStart setCompletionBlock:^(AVPTransition *transition) {
        NSLog(@"Transition %@ completionBlock invoked", transition);
    } transitionLifeCycle:AVPTransitionLifeCycleWillTransition];

    ////////////////////////////////////////////
    
    // use it in unit tests, may takes some time for traversing
    NSError *error = nil;
    
    if ([_stateMachine isValidWithError:&error] == NO) {
        NSLog(@"state machine failed with error: %@", error);
    }
    
}

- (void)start {
    
    [self.stateMachine start];
    
}

#pragma mark - State machine delegate methods

- (void)stateMachineCompletedWithSuccessState:(AVPStateMachine *)stateMachine {
    NSLog(@"State machine '%@' finish successfully", stateMachine.name);
}

- (void)stateMachineCompletedWithFailureState:(AVPStateMachine *)stateMachine {
    NSLog(@"State machine '%@' is failed", stateMachine.name);
}

- (void)stateMachineCompletedWithCancelState:(AVPStateMachine *)stateMachine {
    NSLog(@"State machine '%@' is cancelled", stateMachine.name);
}

@end
