//
//  SPSimpleMovieClip.m
//  Sparrow
//
//  Created by Larry Li on 8/12/15.
//  Copyright 2015 Larry Li. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPSimpleMovieClip.h"

@interface SPSimpleMovieClip ()

@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic) NSUInteger numFrames;
@property (nonatomic) NSUInteger currentFrameIndex;
@property (nonatomic) float timePassed;
@property (nonatomic) float secondsPerFrame;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isComplete;

@end

@implementation SPSimpleMovieClip

+ (instancetype)movieWithFrames: (SP_GENERIC(NSArray,SPTexture*) *)textures fps:(float)fps
{
    return [[[[self class] alloc] initWithFrames: textures fps: fps initialFrame: 0] autorelease];
}

+ (instancetype)movieWithFrames:(SP_GENERIC(NSArray,SPTexture*) *)textures fps:(float)fps initialFrame:(NSUInteger)frameIndex
{
    return [[[[self class] alloc] initWithFrames: textures fps: fps initialFrame: frameIndex] autorelease];
}

- (instancetype)initWithFrames:(SP_GENERIC(NSArray,SPTexture*) *)textures fps:(float)fps initialFrame:(NSUInteger)frameIndex
{
    if( textures.count == 0 ) {
        [NSException raise:SPExceptionInvalidOperation format:@"empty texture array"];
    }
    NSUInteger initialFrameIndex = frameIndex < textures.count ? frameIndex : 0;
    self = [super initWithTexture: textures[initialFrameIndex]];
    if (self) {
        _frames = [[NSMutableArray alloc] initWithArray: textures];
        _numFrames = _frames.count;
        _isPlaying = YES;
        _loop = YES;
        self.fps = fps;
    }
    return self;
}

- (void)dealloc
{
    [_frames release];
    [super dealloc];
}

- (void)advanceTime:(double)seconds
{
    if( _isPlaying ) {
        _timePassed += seconds;
        if( _timePassed >= _secondsPerFrame ) {
            _timePassed = 0.0;
            if( _currentFrameIndex < _numFrames ) {
                [self setTexture: _frames[_currentFrameIndex]];
            }
            ++_currentFrameIndex;
            if( _currentFrameIndex >= _numFrames ) {
                if( _loop ) {
                    _currentFrameIndex = 0;
                } else {
                    self.isComplete = YES;
                }
            }
        }
    }
}

- (void)setFps:(float)fps
{
    if( !SPIsFloatEqual(_fps, fps) ) {
        _fps = fps;
        _secondsPerFrame = 1.0f / _fps;
    }
}

- (void)setIsComplete:(BOOL)isComplete
{
    if( _isComplete != isComplete ) {
        _isComplete = isComplete;
        _isPlaying = NO;
        _currentFrameIndex = 0;
        if( _dispatchCompleteEvent && _isComplete ) {
            [self dispatchEventWithType:SPEventTypeCompleted];
        }
    }
}

- (void)setCurrentFrameIndex:(NSUInteger)currentFrameIndex
{
    if( currentFrameIndex < _numFrames ) {
        _currentFrameIndex = currentFrameIndex;
        [self setTexture: _frames[_currentFrameIndex]];
    }
}

- (void)play
{
    _isPlaying = YES;
    _isComplete = NO;
}

- (void)pause
{
    _isPlaying = NO;
}

- (void)stop
{
    _isPlaying = NO;
    _currentFrameIndex = 0;
    _isComplete = NO;
}

@end
