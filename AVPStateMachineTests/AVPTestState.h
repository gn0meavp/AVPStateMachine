//
//  AVPTestState.h
//  TestOrg
//
//  Created by Alexey Patosin on 07/08/14.
//  Copyright (c) 2014 TestOrg. All rights reserved.
//

#import "AVPState.h"

@interface AVPTestSimpleState : AVPState

@end

@interface AVPTestHoldState : AVPState

@end

static NSString * const kTestSimpleFailureEventName = @"kTestSimpleFailureEventName";
@interface AVPTestSimpleFailureState : AVPState

@end

@interface AVPTestSimpleCancelState : AVPState

@end

@interface AVPTestHoldCancellableState : AVPState

@end

static NSString * const kTestYESEventName = @"kTestYESEventName";
@interface AVPTestSimpleStateWithEventResult : AVPState

@end
