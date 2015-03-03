//
//  SampleState1.m
//  AVPStateMachineConsoleDemo
//
//  Created by Alexey Patosin on 27/02/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import "SampleState1.h"

@implementation SampleState1

- (void)start {
    [super start];
    
    NSLog(@"Do!");
    
    NSUInteger randValue = arc4random()%4;
    
    if (randValue == 0) {
        
        // passing some object to the next state
        self.outputObject = @"Sample description that should be transfered to the Re";
        
        [self performDelegateMethodCompletedWithEventName:kDoReEventName error:nil];
    }
    else if (randValue == 1) {
        [self performDelegateMethodCompletedWithEventName:kDoFaEventName error:nil];
    }
    else if (randValue == 2) {
        [self performDelegateMethodCompletedWithEventName:kDoDoEventName error:nil];
    }
    else {
        [self performDelegateMethodCompletedWithEventName:kDoFailedEventName error:nil];
    }
}

@end
