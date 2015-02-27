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

#import <Foundation/Foundation.h>

#import "AVPState.h"
#import "AVPFinalState.h"
#import "AVPTransition.h"

@class AVPStateMachine;

@protocol AVPStateMachineDelegate <NSObject>

- (void)stateMachineCompletedWithSuccessState:(AVPStateMachine *)stateMachine;
- (void)stateMachineCompletedWithFailureState:(AVPStateMachine *)stateMachine;
- (void)stateMachineCompletedWithCancelState:(AVPStateMachine *)stateMachine;

@end

@interface AVPStateMachine : NSObject < AVPStateDelegate >

@property (nonatomic, strong) AVPFinalState *successFinalState;
@property (nonatomic, strong) AVPFinalState *failureFinalState;
@property (nonatomic, strong) AVPFinalState *cancelFinalState;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) id < AVPStateMachineDelegate > delegate;

@property (nonatomic, strong) AVPState *startState;
@property (nonatomic, strong, readonly) NSSet *states;

@property (nonatomic, strong, readonly) NSError *error;

- (instancetype)init __attribute__((unavailable("use initWithName:delegate: method instead")));
- (instancetype)initWithName:(NSString *)name delegate:(id< AVPStateMachineDelegate >)delegate;

// States
- (void)addState:(AVPState *)state;
- (void)addStates:(NSArray *)states;
- (AVPState *)currentState;

- (BOOL)isInState:(AVPState *)state;
- (BOOL)isInStateWithName:(NSString *)stateName;

// Transitions
- (void)addTransition:(AVPTransition *)transition eventName:(NSString *)eventName;
- (NSDictionary *)transitionsForState:(AVPState *)state;
- (AVPTransition *)transitionForState:(AVPState *)state eventName:(NSString *)eventName;

// Main Logic
- (void)start;
- (void)cancel; // go to final state

// Helpers
- (BOOL)isRunning;

@end

static NSString * const kAVPStateMachineValidationErrorDomain = @"kAVPStateMachineValidationErrorDomain";

static NSString * const kAVPStateMachineValidationErrorUserInfoStateKey = @"kAVPStateMachineValidationErrorUserInfoStateKey";
static NSString * const kAVPStateMachineValidationErrorUserInfoNotUsedStatesKey = @"kAVPStateMachineValidationErrorUserInfoNotUsedStatesKey";
static NSString * const kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey = @"kAVPStateMachineValidationErrorUserInfoStatesWithSameNameKey";

typedef NS_ENUM(NSInteger, kAVPStateMachineValidationErrorCode) {
    kAVPStateMachineValidationErrorCode_MissedStates,        // missed start state or one of final states
    kAVPStateMachineValidationErrorCode_FinishedNotAtFinalState, // some state does not have any transitions to next states or final state
    kAVPStateMachineValidationErrorCode_NotUsedStates,            // some states can't be visited by traversing from start state
    kAVPStateMachineValidationErrorCode_StatesWithSameName       // some states have the same name
};

@interface AVPStateMachine (Validation)
- (BOOL)isValidWithError:(NSError **)error;  // recommended to use at unit tests for example. May takes some time on prod.
@end