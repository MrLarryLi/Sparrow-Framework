//
//  SPBaseEffect.h
//  Sparrow
//
//  Created by Daniel Sperl on 12.03.13.
//  Copyright 2011-2015 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SparrowBase.h>

NS_ASSUME_NONNULL_BEGIN

@class SPMatrix;
@class SPMatrix3D;
@class SPTexture;

/** ------------------------------------------------------------------------------------------------
 
 An SPBaseEffect simplifies the rendering of colored and/or textured polygons.
 
 Configure a base effect by updating its state properties. When you call `prepareToDraw`, it
 will choose the optimal shader program for the given settings and will activate that program.
 Alpha and matrix uniforms will be passed to the program automatically, and the texture will be
 bound.
 
------------------------------------------------------------------------------------------------- */

@interface SPBaseEffect : NSObject

/// -------------
/// @name Methods
/// -------------

/// Activates the optimal shader program for the current settings; alpha and matrix uniforms are
/// passed to the program right away, and the texture (if available) is bound.
- (void)prepareToDraw;

/// ----------------
/// @name Properties
/// ----------------

/// The modelview-projection matrix used for rendering. Any vertex will be multiplied with this
/// matrix. (Default: identity matrix)
@property (nonatomic, copy) SPMatrix *mvpMatrix;

/// The 3D modelview-projection matrix used for rendering. Any vertex will be multiplied with this
/// matrix. (Default: identity matrix)
@property (nonatomic, copy) SPMatrix3D *mvpMatrix3D;

/// The texture that's projected onto the quad, or `nil` if there is none. (Default: `nil`)
@property (nonatomic, strong, nullable) SPTexture *texture;

/// Indicates if the color values of texture and vertices use premultiplied alpha. (Default: `NO`)
@property (nonatomic, assign) BOOL premultipliedAlpha;

/// The alpha value with which every vertex color will be multiplied. (Default: 1)
@property (nonatomic, assign) float alpha;

/// The index of the vertex attribute storing the position vector.
@property (nonatomic, readonly) int attribPosition;

/// The index of the vertex attribute storing the two texture coordinates.
@property (nonatomic, readonly) int attribTexCoords;

/// The index of the vertex attribute storing the color vector.
@property (nonatomic, readonly) int attribColor;

@end

NS_ASSUME_NONNULL_END
