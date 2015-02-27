//
//  SampleStateState.m
//  AVPStateMachineConsoleDemo
//
//  Created by Alexey Patosin on 27/02/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import "SampleStartState.h"

@implementation SampleStartState

- (void)start {
    NSLog(@"Let's sing a song!");
    [self performDelegateMethodCompletedWithEventName:kSampleStartEventName error:nil];
}

@end
