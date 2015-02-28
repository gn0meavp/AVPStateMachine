//
//  AVPFinalStateTests.m
//  TestOrg
//
//  Created by Alexey Patosin on 08/08/14.
//  Copyright (c) 2014 TestOrg. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AVPFinalState.h"

@interface AVPMockFinalStateDelegate : NSObject < AVPStateDelegate >

@end

@interface AVPFinalStateTests : XCTestCase
@property (nonatomic, strong) AVPMockFinalStateDelegate *stateDelegate;
@end

@implementation AVPFinalStateTests


- (void)setUp {
    
    self.stateDelegate = [[AVPMockFinalStateDelegate alloc] init];
    
}

- (void)testFinalStateShouldCompletedSuccessfullyImmediately {

    AVPFinalState *finalState = [[AVPFinalState alloc] initWithName:@"name"];
    [finalState setDelegate:self.stateDelegate];
    
    id mockDelegate = OCMPartialMock(self.stateDelegate);
    
    [[mockDelegate expect] stateFinished:finalState eventName:[OCMArg any] error:nil];
    [finalState start];
    [mockDelegate verify];
    
}

@end

@implementation AVPMockFinalStateDelegate

- (void)stateStarted:(AVPState *)state {}
- (void)stateFinished:(AVPState *)state eventName:(NSString *)eventName error:(NSError *)error {}
- (void)stateCancelled:(AVPState *)state {}

@end
