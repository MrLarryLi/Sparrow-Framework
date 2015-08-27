//
//  SPQuadBatchStack.m
//  Sparrow
//
//  Created by Larry Li on 8/10/15.
//  Copyright 2015 Larry Li. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPQuadBatchStack.h"
#import "SPQuadBatch.h"
#import "SPNSExtensions.h"

@implementation SPQuadBatchStack
{
    SP_GENERIC(NSMutableArray,SPQuadBatch*) *_quadBatches;
    NSInteger _quadBatchIndex;
    NSInteger _quadBatchSize;

}

+ (instancetype)newStack
{
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _quadBatches = [[NSMutableArray alloc] initWithObjects:[self newQuadBatch], nil];
        _quadBatchIndex = 0;
        _quadBatchSize = 1;
        _quadBatchTop = _quadBatches[0];
    }
    return self;
}

- (void)dealloc
{
    [_quadBatches release];
    [super dealloc];
}

- (SPQuadBatch *)topQuadBatch
{
    return _quadBatchTop;
}

- (void)purgeBuffers
{
    [_quadBatches removeAllObjects];
    
    _quadBatchTop = [self newQuadBatch];
    [_quadBatches addObject:_quadBatchTop];
    
    _quadBatchIndex = 0;
    _quadBatchSize = 1;
}

- (void)prepForNextFrame
{
    _quadBatchIndex = 0;
    _quadBatchTop = _quadBatches[0];
}

- (void)trimQuadBatches
{
    NSInteger numUsedBatches = _quadBatchIndex + 1;
    if (_quadBatchSize >= 16 && _quadBatchSize > 2 * numUsedBatches)
    {
        NSInteger numToRemove = _quadBatchSize - numUsedBatches;
        [_quadBatches removeObjectsInRange:(NSRange){ _quadBatchSize-numToRemove-1, numToRemove }];
        _quadBatchSize = (int)_quadBatches.count;
    }
}

- (void)renderWithMatrix:(SPMatrix3D *)matrix
{
    if (_quadBatchTop.numQuads)
    {
        [_quadBatchTop renderWithMvpMatrix3D: matrix];
    }
}

- (void)resetStack
{
    if (_quadBatchTop.numQuads)
    {
        [_quadBatchTop reset];
        
        if (_quadBatchSize == _quadBatchIndex + 1)
        {
            [_quadBatches addObject:[self newQuadBatch]];
            ++_quadBatchSize;
        }
        _quadBatchTop = _quadBatches[++_quadBatchIndex];
    }
}

- (SPQuadBatch *)newQuadBatch
{
    static BOOL forceTinted = YES;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
      {
          NSString *platform = [[UIDevice currentDevice] platform];
          NSString *version  = [[UIDevice currentDevice] platformVersion];
          
          if ([platform containsString:@"iPhone"])
          {
              // disable for iPhone 4 and below
              if ([[version substringToIndex:1] integerValue] < 4)
                  forceTinted = NO;
          }
          else if ([platform containsString:@"iPad"])
          {
              // disable for iPad 1
              if ([[version substringToIndex:1] integerValue] < 2)
                  forceTinted = NO;
          }
      });
    
    SPQuadBatch *quadBatch = [[SPQuadBatch alloc] init];
    quadBatch.forceTinted = forceTinted;
    return [quadBatch autorelease];
}

@end
