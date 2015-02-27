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

#import "AVPTransition.h"
#import "AVPFinalState.h"

@interface AVPTransition ()

@property (nonatomic, strong) NSMutableDictionary *transitionCompletionBlocks;

@end

@implementation AVPTransition

- (instancetype)initWithFromState:(AVPState *)fromState
                     toState:(AVPState *)toState {
    self = [super init];
    
    if (self) {
        NSParameterAssert(fromState);
        NSParameterAssert(toState);
        NSAssert([fromState isKindOfClass:[AVPFinalState class]] == NO, @"incorrect initialization – AVPFinalState cannot have any transitions!");
        
        _fromState = fromState;
        _toState = toState;
        _transitionCompletionBlocks = [NSMutableDictionary dictionary];
    }

    return self;
}

+ (instancetype)transitionWithFromState:(AVPState *)fromState
                                toState:(AVPState *)toState {
    return [[[self class] alloc] initWithFromState:fromState toState:toState];
}

#pragma mark - completion blocks

- (void)setCompletionBlock:(AVPTransitionCompletionBlock)completionBlock transitionLifeCycle:(AVPTransitionLifeCycle)transitionLifeCycle {
    self.transitionCompletionBlocks[[self completionBlockKeyForTransitionLifeCycle:transitionLifeCycle]] = completionBlock;
}

- (void)invokeCompletionBlockForTransitionLifeCycle:(AVPTransitionLifeCycle)transitionLifeCycle {
    AVPTransitionCompletionBlock block = (AVPTransitionCompletionBlock)self.transitionCompletionBlocks[[self completionBlockKeyForTransitionLifeCycle:transitionLifeCycle]];
    
    if (block) {
        block(self);
    }
}

- (id <NSCopying>)completionBlockKeyForTransitionLifeCycle:(AVPTransitionLifeCycle)transitionLifeCycle {
    return @(transitionLifeCycle);
}

@end
