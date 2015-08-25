//
//  SPSimpleMovieClip.h
//  Sparrow
//
//  Created by Larry Li on 8/12/15.
//  Copyright 2015 Larry Li. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SPImage.h>
#import <Sparrow/SPAnimatable.h>

/** ------------------------------------------------------------------------------------------------
 
 SPSimpleMovieClip is a more simplified version of SPMovieClip.
 
 It uses less resources than SPMovieClip, but it doesn't support extra features.
 It only supports drawing textures at a fixed FPS. The frames can't be changed.
 
 The advanceTime: method must be called for it to animate.
 
 ------------------------------------------------------------------------------------------------- */

@interface SPSimpleMovieClip : SPImage <SPAnimatable>

/// --------------------
/// @name Initialization
/// --------------------

/// Designated initializer. The initial frame can be specified.
+ (instancetype)movieWithFrames: (SP_GENERIC(NSArray,SPTexture*) *)textures fps:(float)fps initialFrame: (NSUInteger)frameIndex;

/// Defaults to showing the first frame.
+ (instancetype)movieWithFrames: (SP_GENERIC(NSArray,SPTexture*) *)textures fps:(float)fps;

/// Designated intializer. Texture count must be more than zero.
- (instancetype)initWithFrames:(SP_GENERIC(NSArray,SPTexture*) *)textures fps:(float)fps initialFrame:(NSUInteger)frameIndex;

/// --------------------------------
/// @name Frame Manipulation Methods
/// --------------------------------

/// Specify the frame to show. This is zero based indexing. If playback is resume, it will start with this frame.
- (void)setCurrentFrameIndex: (NSUInteger)currentFrameIndex;

/// ----------------------
/// @name Playback Methods
/// ----------------------

/// Will begin playback.
- (void)play;

/// Will pause playback. Does not rewind.
- (void)pause;

/// Will stop playback. This will always rewind to first frame.
- (void)stop;

/// ----------------
/// @name Properties
/// ----------------

/// Frame count.
@property (nonatomic, readonly) NSUInteger numFrames;

/// Only true if it played to the last frame and isn't looping.
@property (nonatomic, readonly) BOOL isComplete;

/// Default is YES;
@property (nonatomic, readonly) BOOL isPlaying;

/// Default is NO.
@property (nonatomic) BOOL dispatchCompleteEvent;

/// Default is YES.
@property (nonatomic) BOOL loop;

/// Time spend per frame is 1 divided by the FPS.
@property (nonatomic) float fps;

@end
