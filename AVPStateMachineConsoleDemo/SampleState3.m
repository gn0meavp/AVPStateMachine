//
//  SampleState3.m
//  AVPStateMachineConsoleDemo
//
//  Created by Alexey Patosin on 27/02/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import "SampleState3.h"

@implementation SampleState3

- (void)start {
    [super start];
    
    NSLog(@"Mi");        
    [self performDelegateMethodCompletedWithEventName:kMiSuccessEventName error:nil];
}

@end
