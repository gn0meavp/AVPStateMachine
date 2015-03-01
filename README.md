# AVPStateMachine
Implementation of Finite-state Machine in Objective-C

# Features
* States inherited from the basic State class
* Transitions use for connecting States by the coming Events
* Special States for start and completion (success, failure or cancel)
* Cancellation supports for any State

# Usage

## Demo

See AVPStateMachineConsoleDemo project as a sample

## Example

### Overview

Let's create simple finite-state machine which plays Do-Re-Mi and Do-Fa in different cases.

AVPStateMachine supports separate States for start and completion (<i>AVPFinalState</i>) so we could manage them with additional logic.

To make our sample more complex, let's imagine that during playing Do and Fa something may happened and we must fail the whole process. In these cases state machine should go to the failure final state.

So our complete state machine will look like that:

<img src="https://github.com/gn0meavp/AVPStateMachine/raw/gn0meavp-patch-1/manual/sample-scheme-01.png" alt="asdf" width="300">

### Creating State Machine

The easiest part is to create the state machine:

```objectivec
stateMachine = [[AVPStateMachine alloc] initWithName:@"Test state machine" delegate:self];
```

Don't forget about delegate methods:

```objective-c
- (void)stateMachineCompletedWithSuccessState:(AVPStateMachine *)stateMachine {
    NSLog(@"State machine '%@' finish successfully", stateMachine.name);
}

- (void)stateMachineCompletedWithFailureState:(AVPStateMachine *)stateMachine {
    NSLog(@"State machine '%@' is failed", stateMachine.name);
}

- (void)stateMachineCompletedWithCancelState:(AVPStateMachine *)stateMachine {
    NSLog(@"State machine '%@' is cancelled", stateMachine.name);
}
```

### Creating States

Each state should be inherited from one of the base states <i>AVPState</i> or <i>AVPFinalState</i>. So let's create some of them.

```objective-c
static NSString * const kDoReEventName = @"kDoReEventName";
static NSString * const kDoFaEventName = @"kDoFaEventName";
static NSString * const kDoFailedEventName = @"kDoFailedEventName";

@interface SampleState1 : AVPState

@end
```

Here we created a sample State and define events which will be used in that state for the transitions.

Inside <i>start</i> method must be implemented the logic for the certain state. It could be implemented in a sync or async way

```objective-c

- (void)start {
    [super start];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Do!");
        
        NSUInteger randValue = arc4random()%3;
        
        if (randValue == 0) {
            [self performDelegateMethodCompletedWithEventName:kDoReEventName error:nil];
        }
        else if (randValue == 1) {
            [self performDelegateMethodCompletedWithEventName:kDoFaEventName error:nil];
        }
        else {
            [self performDelegateMethodCompletedWithEventName:kDoFailedEventName error:nil];
        }
    });
}
```
Here we implemented a sample async logic of the Do State with some random behavior to switch to Re, Fa or Failed State.

Now we could initialize this state:

```objectivec
    SampleState1 *doState = [SampleState1 stateWithName:@"Do state"];
```

### Append States to State Machine

After creating all states, let's add them to our State Machine:

```objective-c
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
```

### Create transitions

Now we need to manage our State Machine to switch between states with using Events:

```objectivec
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
```
