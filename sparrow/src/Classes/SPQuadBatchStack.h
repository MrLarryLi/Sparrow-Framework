//
//  SPQuadBatchStack.h
//  Sparrow
//
//  Created by Larry Li on 8/10/15.
//  Copyright 2015 Larry Li. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPQuadBatch;
@class SPMatrix3D;

/** ------------------------------------------------------------------------------------------------
 
Maintains the stack of SPQuadBatch objects. 
 
Do not retain or hold a reference to the top SPQuadBatch. It will change without notice. Always 
access it directly when needed.

 ------------------------------------------------------------------------------------------------- */

@interface SPQuadBatchStack : NSObject
{
    @public
    SPQuadBatch *_quadBatchTop;
}

+ (instancetype)newStack;

/// Removes all data from the stack. It effectively creates a new stack.
- (void)purgeBuffers;

/// Resets to bottom of the stack.
- (void)prepForNextFrame;

/// Removes extra SPQuadBatch objects.
- (void)trimQuadBatches;

/// Renders with the matrix provided.
- (void)renderWithMatrix3D: (SPMatrix3D *)matrix;

/// Resets and provides a new quadbatch top
- (void)resetStack;

@end
