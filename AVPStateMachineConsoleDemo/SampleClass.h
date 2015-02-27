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

//  Implementation of the next Activity Diagram
//
//      Start -> DO -> RE -> MI -> Success (accessible from MI and FA)
//                \           /
//                 -> --FA ---
//                  \     \
//                   ----------->  Failure (accessible from states which can be failed)
//
//                                 Cancel  (accessible from any state if cancel state machine)
//


//  Result output:
//        Let's sing a song!
//        state 'start state' worked nan sec.
//        #state_machine 'Test state machine' stateFinished: 'start state' eventName: 'kSampleStartEventName' error: '(null)'
//        #state_machine 'Test state machine' stateStarted: 'Do state'
//        Do!
//        state 'Do state' worked 0.000291 sec.
//        #state_machine 'Test state machine' stateFinished: 'Do state' eventName: 'kDoReEventName' error: '(null)'
//        #state_machine 'Test state machine' stateStarted: 'Re state'
//        Re
//        state 'Re state' worked 0.000239 sec.
//        #state_machine 'Test state machine' stateFinished: 'Re state' eventName: 'kReMiEventName' error: '(null)'
//        #state_machine 'Test state machine' stateStarted: 'Mi state'
//        Mi
//        state 'Mi state' worked 0.000261 sec.
//        #state_machine 'Test state machine' stateFinished: 'Mi state' eventName: 'kMiSuccessEventName' error: '(null)'
//        #state_machine 'Test state machine' stateStarted: 'success'
//        state 'success' worked 0.000115 sec.
//        #state_machine 'Test state machine' stateFinished: 'success' eventName: 'kFinalStateCompletedEventName' error: '(null)'
//        State machine 'Test state machine' finish successfully

@interface SampleClass : NSObject

- (void)start;

@end
