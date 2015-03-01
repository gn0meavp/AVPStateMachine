//
//  SampleState2.m
//  AVPStateMachineConsoleDemo
//
//  Created by Alexey Patosin on 27/02/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import "SampleState2.h"

@implementation SampleState2

- (void)start {
    [super start];    
    
    if (self.inputObject) {
        NSLog(@"Get some object from the previous state: %@", self.inputObject);
    }
    
    NSLog(@"Re");    
    [self performDelegateMethodCompletedWithEventName:kReMiEventName error:nil];
}

@end
