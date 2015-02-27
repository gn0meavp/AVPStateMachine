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
    
    NSLog(@"Re");    
    [self performDelegateMethodCompletedWithEventName:kReMiEventName error:nil];
}

@end
