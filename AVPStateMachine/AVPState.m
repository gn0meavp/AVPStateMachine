// The MIT License (MIT)
//
// Copyright (c) 2014 Alexey Patosin http://alexey.patosin.ru
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AVPState.h"

@interface AVPState ()
@property (atomic, readwrite) BOOL isRunning;
@property (atomic, readwrite) BOOL isCancelled;

@property (nonatomic, strong) NSMutableDictionary *stateCompletionBlocks;

@property (nonatomic, strong) NSDate *startDate;        // datetime when event was started (if was started)
@property (nonatomic, strong) NSDate *finishDate;       // datetime when event was stopped, (if was finished or cancelled or error occured)
@property (nonatomic, strong) NSDate *cancelingDate;    // datetime when cancel event was triggered
@property (nonatomic, strong) NSDate *cancelledDate;    // datetime when state was cancelled (cancellation may takes some time)

@end

@implementation AVPState

- (instancetype)initWithName:(NSString *)name {
 
    self = [super init];
    
    if (self) {
        
        NSParameterAssert(name);
        _name = name;
        _stateCompletionBlocks = [NSMutableDictionary dictionary];
        
    }
    
    return self;
    
}

+ (instancetype)stateWithName:(NSString *)name {
    
    return [[[self class] alloc] initWithName:name];
}

#pragma mark - setters

- (void)setFinishDate:(NSDate *)finishDate {
    
    _finishDate = finishDate;
    
    NSLog(@"state '%@' worked %f sec.", self.name, [self.finishDate timeIntervalSinceDate:self.startDate]);
    
}

- (void)setCancelledDate:(NSDate *)cancelledDate {
    
    _cancelledDate = cancelledDate;
    
    NSLog(@"state '%@' cancelled in %f sec", self.name, [self.cancelledDate timeIntervalSinceDate:self.cancelingDate]);
    
}

#pragma mark - helper methods

- (NSString *)description {
    
    return [NSString stringWithFormat:@"State with name '%@'. isRunning: %i, isCancelled: %i", self.name,
            self.isRunning, self.isCancelled];
    
}

#pragma mark - main logic

- (void)start {

    self.isRunning = YES;

    [self performDelegateMethodStart];
    
}

- (void)cancel {
 
    self.isCancelled = YES;
    self.cancelingDate = [NSDate date];
    
    // job have to be cancelled at descendants and called performDelegateMethodCancel

}

#pragma mark - completion blocks 

- (void)setCompletionBlock:(AVPStateCompletionBlock)completionBlock stateLifeCycle:(AVPStateLifeCycle)stateLifeCycle {
    
    self.stateCompletionBlocks[[self completionBlockKeyForStateLifeCycle:stateLifeCycle]] = completionBlock;
    
}

- (void)invokeCompletionBlockForStateLifeCycle:(AVPStateLifeCycle)stateLifeCycle {
    
    AVPStateCompletionBlock block = (AVPStateCompletionBlock)self.stateCompletionBlocks[[self completionBlockKeyForStateLifeCycle:stateLifeCycle]];
    
    if (block) {
        
        block(self);
        
    }
    
}

- (NSString *)completionBlockKeyForStateLifeCycle:(AVPStateLifeCycle)stateLifeCycle {
    
    return [NSString stringWithFormat:@"%ld", (long)stateLifeCycle];
    
}

#pragma mark - date methods

- (NSDate *)datetimeForStateEvent:(AVPStateDateType)eventType {
    
    switch (eventType) {
        case AVPStateDateTypeStart:
            return self.startDate;
        case AVPStateDateTypeFinish:
            return self.finishDate;
        case AVPStateDateTypeCancel:
            return self.cancelingDate;
        case AVPStateDateTypeCancelled:
            return self.cancelledDate;
            
        default:
            NSAssert(NO, @"unknown AVPStateDateType type %ld", (long)eventType);
            return nil;
    }
    
}

#pragma mark - perform delegate methods

- (void)performDelegateMethodStart {
    
    self.startDate = [NSDate date];
    
    [self.delegate stateStarted:self];
    
}

- (void)performDelegateMethodCompletedWithEventName:(NSString *)eventName error:(NSError *)error {
    
    self.isRunning = NO;
    
    self.finishDate = [NSDate date];
    
    [self.delegate stateFinished:self eventName:eventName error:error];
    
}

- (void)performDelegateMethodCancel {
    
    self.isRunning = NO;
    
    self.cancelledDate = [NSDate date];
    self.finishDate = self.cancelledDate;
    
    [self.delegate stateCancelled:self];
    
}

@end
