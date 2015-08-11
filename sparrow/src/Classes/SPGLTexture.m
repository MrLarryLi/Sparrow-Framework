//
//  SPGLTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011-2014 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SparrowClass.h"
#import "SPContext_Internal.h"
#import "SPGLTexture_Internal.h"
#import "SPMacros.h"
#import "SPOpenGL.h"
#import "SPPVRData.h"
#import "SPRectangle.h"

@implementation SPGLTexture
{
    SPTextureFormat _format;
    SPTextureSmoothing _smoothing;
    uint _name;
    uint _framebuffer;
    uint _depthAndStencilRenderbuffer;
    float _width;
    float _height;
    float _scale;
    BOOL _repeat;
    BOOL _premultipliedAlpha;
    BOOL _mipmaps;
}

@synthesize name = _name;
@synthesize repeat = _repeat;
@synthesize premultipliedAlpha = _premultipliedAlpha;
@synthesize scale = _scale;
@synthesize format = _format;
@synthesize mipmaps = _mipmaps;
@synthesize smoothing = _smoothing;

// --- c functions ---

SP_INLINE void checkDepthAndStencilBuffer(SPGLTexture *texture, BOOL enableDepthAndStencil)
{
    if (enableDepthAndStencil && !texture->_depthAndStencilRenderbuffer)
    {
        glGenRenderbuffers(1, &texture->_depthAndStencilRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, texture->_depthAndStencilRenderbuffer);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, texture->_depthAndStencilRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, texture->_depthAndStencilRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, texture->_width, texture->_height);
    }
}

SP_INLINE void affirmFramebuffer(SPGLTexture *texture, BOOL enableDepthAndStencil)
{
    if (texture->_framebuffer == 0 || (enableDepthAndStencil && !texture->_depthAndStencilRenderbuffer))
    {
        int prevFramebuffer = -1;
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &prevFramebuffer);
        
        if (texture->_framebuffer == 0)
        {
            glGenFramebuffers(1, &texture->_framebuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, texture->_framebuffer);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture->_name, 0);
        }
        else
        {
            glBindFramebuffer(GL_FRAMEBUFFER, texture->_framebuffer);
        }
        
        checkDepthAndStencilBuffer(texture, enableDepthAndStencil);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"[Sparrow] failed to create framebuffer for texture.");
        
        glBindFramebuffer(GL_FRAMEBUFFER, prevFramebuffer);
    }
}

#pragma mark Initialization

- (instancetype)initWithName:(uint)name format:(SPTextureFormat)format
                       width:(float)width height:(float)height containsMipmaps:(BOOL)mipmaps
                       scale:(float)scale premultipliedAlpha:(BOOL)pma;
{
    if ((self = [super init]))
    {
        if (width <= 0.0f)  [NSException raise:SPExceptionInvalidOperation format:@"invalid width"];
        if (height <= 0.0f) [NSException raise:SPExceptionInvalidOperation format:@"invalid height"];
        if (scale <= 0.0f)  [NSException raise:SPExceptionInvalidOperation format:@"invalid scale"];
        
        _name = name;
        _width = width;
        _height = height;
        _mipmaps = mipmaps;
        _scale = scale;
        _premultipliedAlpha = pma;
        _format = format;

        _repeat = YES; // force first update
        self.repeat = NO;
        self.smoothing = SPTextureSmoothingBilinear;
    }
    
    return self;
}

- (instancetype)initWithData:(const void *)imgData properties:(SPTextureProperties)properties
{
    GLenum glTexType = GL_UNSIGNED_BYTE;
    GLenum glTexFormat;
    GLuint glTexName;
    int bitsPerPixel;
    BOOL compressed = NO;
    
    switch (properties.format)
    {
        default:
        case SPTextureFormatRGBA:
            bitsPerPixel = 32;
            glTexFormat = GL_RGBA;
            break;
        case SPTextureFormatAlpha:
            bitsPerPixel = 8;
            glTexFormat = GL_ALPHA;
            break;
        case SPTextureFormatPvrtcRGBA2:
            compressed = YES;
            bitsPerPixel = 2;
            glTexFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
            break;
        case SPTextureFormatPvrtcRGB2:
            compressed = YES;
            bitsPerPixel = 2;
            glTexFormat = GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
            break;
        case SPTextureFormatPvrtcRGBA4:
            compressed = YES;
            bitsPerPixel = 4;
            glTexFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
            break;
        case SPTextureFormatPvrtcRGB4:
            compressed = YES;
            bitsPerPixel = 4;
            glTexFormat = GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
            break;
        case SPTextureFormat565:
            bitsPerPixel = 16;
            glTexFormat = GL_RGB;
            glTexType = GL_UNSIGNED_SHORT_5_6_5;
            break;
        case SPTextureFormat888:
            bitsPerPixel = 24;
            glTexFormat = GL_RGB;
            break;
        case SPTextureFormat5551:
            bitsPerPixel = 16;
            glTexFormat = GL_RGBA;
            glTexType = GL_UNSIGNED_SHORT_5_5_5_1;
            break;
        case SPTextureFormat4444:
            bitsPerPixel = 16;
            glTexFormat = GL_RGBA;
            glTexType = GL_UNSIGNED_SHORT_4_4_4_4;
            break;
        case SPTextureFormatAI88:
            bitsPerPixel = 16;
            glTexFormat = GL_LUMINANCE_ALPHA;
            break;
        case SPTextureFormatI8:
            bitsPerPixel = 8;
            glTexFormat = GL_LUMINANCE;
    }
    
    glGenTextures(1, &glTexName);
    glBindTexture(GL_TEXTURE_2D, glTexName);
    
    if (!compressed)
    {
        int levelWidth  = (int)properties.width;
        int levelHeight = (int)properties.height;
        unsigned char *levelData = (unsigned char *)imgData;
        
        for (int level=0; level<=properties.numMipmaps; ++level)
        {
            int size = levelWidth * levelHeight * bitsPerPixel / 8;
            glTexImage2D(GL_TEXTURE_2D, level, glTexFormat, levelWidth, levelHeight,
                         0, glTexFormat, glTexType, levelData);
            levelData += size;
            levelWidth  /= 2;
            levelHeight /= 2;
        }
        
        if (properties.numMipmaps == 0 && properties.generateMipmaps)
            glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        int levelWidth  = (int)properties.width;
        int levelHeight = (int)properties.height;
        unsigned char *levelData = (unsigned char *)imgData;
        
        for (int level=0; level<=properties.numMipmaps; ++level)
        {
            int size = MAX(32, levelWidth * levelHeight * bitsPerPixel / 8);
            glCompressedTexImage2D(GL_TEXTURE_2D, level, glTexFormat,
                                   levelWidth, levelHeight, 0, size, levelData);
            levelData += size;
            levelWidth  /= 2;
            levelHeight /= 2;
        }
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    BOOL containsMipmaps = properties.numMipmaps > 0 || (properties.generateMipmaps && !compressed);
    
    return [self initWithName:glTexName format:properties.format
                        width:properties.width height:properties.height
              containsMipmaps:containsMipmaps scale:properties.scale
           premultipliedAlpha:properties.premultipliedAlpha];
}

- (instancetype)initWithPVRData:(SPPVRData *)pvrData scale:(float)scale
{
    SPTextureProperties properties = {
        .format = pvrData.format,
        .scale  = scale,
        .width  = pvrData.width,
        .height = pvrData.height,
        .numMipmaps = pvrData.numMipmaps,
        .generateMipmaps = NO,
        .premultipliedAlpha = NO
    };
    
    return [self initWithData:pvrData.imageData properties:properties];
}

- (instancetype)init
{
    return [self initWithName:0 format:SPTextureFormatRGBA width:64 height:64 containsMipmaps:NO
                        scale:1.0f premultipliedAlpha:NO];
}

- (void)dealloc
{
    glDeleteTextures(1, &_name);
    
    if (_framebuffer)
        glDeleteFramebuffers(1, &_framebuffer);
    
    if (_depthAndStencilRenderbuffer)
        glDeleteRenderbuffers(1, &_depthAndStencilRenderbuffer);

    [super dealloc];
}

#pragma mark SPTexture

- (float)width
{
    return _width / _scale;
}

- (float)height
{
    return _height / _scale;
}

- (float)nativeWidth
{
    return _width;
}

- (float)nativeHeight
{
    return _height;
}

- (SPGLTexture *)root
{
    return self;
}

- (void)setRepeat:(BOOL)value
{
    if (value != _repeat)
    {
        _repeat = value;
        glBindTexture(GL_TEXTURE_2D, _name);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _repeat ? GL_REPEAT : GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _repeat ? GL_REPEAT : GL_CLAMP_TO_EDGE);
    }
}

- (void)setSmoothing:(SPTextureSmoothing)filterType
{
    if (filterType != _smoothing)
    {
        _smoothing = filterType;
        glBindTexture(GL_TEXTURE_2D, _name);

        int magFilter, minFilter;

        if (filterType == SPTextureSmoothingNone)
        {
            magFilter = GL_NEAREST;
            minFilter = _mipmaps ? GL_NEAREST_MIPMAP_NEAREST : GL_NEAREST;
        }
        else if (filterType == SPTextureSmoothingBilinear)
        {
            magFilter = GL_LINEAR;
            minFilter = _mipmaps ? GL_LINEAR_MIPMAP_NEAREST : GL_LINEAR;
        }
        else
        {
            magFilter = GL_LINEAR;
            minFilter = _mipmaps ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR;
        }

        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
    }
}

@end

@implementation SPGLTexture (Internal)

- (uint)framebufferWithDepthAndStencil:(BOOL)enableDepthAndStencil
{
    affirmFramebuffer(self, enableDepthAndStencil);
    return _framebuffer;
}

@end
