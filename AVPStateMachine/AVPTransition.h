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
#import "AVPState.h"

@class AVPTransition;

typedef NS_ENUM(NSInteger, AVPTransitionLifeCycle) {
    AVPTransitionLifeCycleWillTransition = 0,
    AVPTransitionLifeCycleDidTransition = 1,
};

typedef void (^AVPTransitionCompletionBlock)(AVPTransition *transition);

@interface AVPTransition : NSObject

@property (nonatomic, strong) AVPState *fromState;
@property (nonatomic, strong) AVPState *toState;

- (void)setCompletionBlock:(AVPTransitionCompletionBlock)completionBlock transitionLifeCycle:(AVPTransitionLifeCycle)transitionLifeCycle;
- (void)invokeCompletionBlockForTransitionLifeCycle:(AVPTransitionLifeCycle)transitionLifeCycle;

- (instancetype)initWithFromState:(AVPState *)fromState
                     toState:(AVPState *)toState;

+ (instancetype)transitionWithFromState:(AVPState *)fromState
                          toState:(AVPState *)toState;

@end