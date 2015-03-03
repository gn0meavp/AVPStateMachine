//
//  SampleState1.h
//  AVPStateMachineConsoleDemo
//
//  Created by Alexey Patosin on 27/02/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVPState.h"

static NSString * const kDoDoEventName = @"kDoDoEventName";
static NSString * const kDoReEventName = @"kDoReEventName";
static NSString * const kDoFaEventName = @"kDoFaEventName";
static NSString * const kDoFailedEventName = @"kDoFailedEventName";

@interface SampleState1 : AVPState

@end
