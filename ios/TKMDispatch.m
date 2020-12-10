//
//  TKMDispatch.m
//  Tsurukame
//
//  Created by Matthew Benedict on 12/7/20.
//  Copyright © 2020 David Sansome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKMDispatch.h"

@implementation TKMDispatch
dispatch_queue_t queue;

- (void) async:(dispatch_block_t)block {
  dispatch_async(queue, block);
}

- (instancetype)init:(const char*)label {
  queue = dispatch_queue_create(label, NULL);
  return self;
}
@end

@implementation TKMDispatchGroup
dispatch_group_t group;

- (void) notify:(TKMDispatch*) queue withBlock: (dispatch_block_t) block {
  dispatch_group_notify(group, queue.queue, block);
}

- (instancetype)init {
  group = dispatch_group_create();
  return self;
}
@end

@implementation UIView (Extended)
- (CGPoint) transferPoint:(CGPoint)point toView:(nullable UIView *)view {
  return [self convertPoint:point toView:view];
}
@end
