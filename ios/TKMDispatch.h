//
//  TKMDispatch.h
//  Tsurukame
//
//  Created by Matthew Benedict on 12/7/20.
//  Copyright © 2020 David Sansome. All rights reserved.
//

#ifndef TKMDispatch_h
#define TKMDispatch_h
NS_ASSUME_NONNULL_BEGIN
@import UIKit;

@interface TKMDispatch: NSObject
@property(nonatomic) dispatch_queue_t queue;

+(TKMDispatch*) main;
+(instancetype) initWithQueue:(dispatch_queue_t)queue;
-(void) async:(dispatch_block_t)block;
-(dispatch_queue_t) getQueue;
-(instancetype) init:(const char*)label;
@end

@interface TKMDispatchGroup: NSObject
-(void) notify:(TKMDispatch*)queue withBlock: (dispatch_block_t) block;
-(void) enter;
-(void) leave;
-(instancetype) init;
@end

@interface UIView (Extended)
- (CGPoint) transferPoint:(CGPoint)point toView:(nullable UIView *)view;
@end

NS_ASSUME_NONNULL_END
#endif /* TKMDispatch_h */
