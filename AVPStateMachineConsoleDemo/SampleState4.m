//
//  SampleState4.m
//  AVPStateMachineConsoleDemo
//
//  Created by Alexey Patosin on 27/02/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import "SampleState4.h"

@implementation SampleState4

- (void)start {
    [super start];
    
    NSLog(@"Fa");
    
    if (arc4random()%2) {
        [self performDelegateMethodCompletedWithEventName:kFaSuccessEventName error:nil];
    }
    else {
        [self performDelegateMethodCompletedWithEventName:kFaFailedEventName error:nil];
    }
}

@end
