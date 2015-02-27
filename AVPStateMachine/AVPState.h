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

#import <Foundation/Foundation.h>

@class AVPState;

typedef void (^AVPStateCompletionBlock)(AVPState *state);

typedef NS_ENUM(NSInteger, AVPStateLifeCycle) {
    AVPStateLifeCycleWillEnter = 0,
    AVPStateLifeCycleDidEnter = 1,
    AVPStateLifeCycleWillLeave = 2,
    AVPStateLifeCycleDidLeave = 3,
};

typedef NS_ENUM(NSInteger, AVPStateDateType) {
    AVPStateDateTypeStart,       // when event was started (if was started)
    AVPStateDateTypeFinish,      // when event was stopped, (if was finished or cancelled or error occured)
    AVPStateDateTypeCancel,      // when cancel event was triggered
    AVPStateDateTypeCancelled    // when state was cancelled (cancellation may takes some time)
};

@protocol AVPStateDelegate;

@interface AVPState: NSObject

@property (nonatomic, weak) id < AVPStateDelegate > delegate;
@property (nonatomic, strong) NSString *name;
@property (atomic, readonly) BOOL isRunning;
@property (atomic, readonly) BOOL isCancelled;
@property (nonatomic, strong) id inputObject;       // set before start
@property (nonatomic, strong) id outputObject;      // provide information for the next state before switch

+ (instancetype)stateWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name;

- (void)start;
- (void)cancel;    // go to final cancel state in state machine at the end

- (void)setCompletionBlock:(AVPStateCompletionBlock)completionBlock stateLifeCycle:(AVPStateLifeCycle)stateLifeCycle;
- (void)invokeCompletionBlockForStateLifeCycle:(AVPStateLifeCycle)stateLifeCycle;

- (NSDate *)datetimeForStateEvent:(AVPStateDateType)eventType;

// Private methods for descendants to call instead of delegate methods directly
- (void)performDelegateMethodStart;
- (void)performDelegateMethodCompletedWithEventName:(NSString *)eventName error:(NSError *)error;
- (void)performDelegateMethodCancel;

@end

@protocol AVPStateDelegate <NSObject>

// start event for the state
- (void)stateStarted:(AVPState *)state;

//// final events for the state
- (void)stateFinished:(AVPState *)state eventName:(NSString *)eventName error:(NSError *)error;
- (void)stateCancelled:(AVPState *)state;

@end
