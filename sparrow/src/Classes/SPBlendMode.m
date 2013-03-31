//
//  SPBlendMode.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.03.13.
//
//

#import "SPBlendMode.h"
#import <GLKit/GLKit.h>

// --- C functions ---------------------------------------------------------------------------------

static inline uint encodeFactor(uint factor)
{
    if (factor == GL_ZERO || factor == GL_ONE) return factor;
    else return (factor & 0xff) + 2;
}

static inline uint decodeFactor(uint factor)
{
    if (factor == GL_ZERO || factor == GL_ONE) return factor;
    else return factor + 0x0300 - 2;
}

static NSString *getNameOfFactor(uint factor)
{
    switch (factor)
    {
        case GL_ZERO:                return @"ZERO"; break;
        case GL_ONE:                 return @"ONE"; break;
        case GL_SRC_COLOR:           return @"SRC_COLOR"; break;
        case GL_ONE_MINUS_SRC_COLOR: return @"ONE_MINUS_SRC_COLOR"; break;
        case GL_SRC_ALPHA:           return @"SRC_ALPHA"; break;
        case GL_ONE_MINUS_SRC_ALPHA: return @"ONE_MINUS_SRC_ALPHA"; break;
        case GL_DST_ALPHA:           return @"DST_ALPHA"; break;
        case GL_ONE_MINUS_DST_ALPHA: return @"ONE_MINUS_DST_ALPHA"; break;
        case GL_DST_COLOR:           return @"DST_COLOR"; break;
        case GL_ONE_MINUS_DST_COLOR: return @"ONE_MINUS_DST_COLOR"; break;
        case GL_SRC_ALPHA_SATURATE:  return @"SRC_ALPHA_SATURATE"; break;
        default:                     return @"unknown";  break;
    }
}

static NSString *getNameOfMode(uint mode)
{
    switch (mode)
    {
        case SP_BLEND_MODE_AUTO:     return @"auto";     break;
        case SP_BLEND_MODE_NONE:     return @"none";     break;
        case SP_BLEND_MODE_NORMAL:   return @"normal";   break;
        case SP_BLEND_MODE_ADD:      return @"add";      break;
        case SP_BLEND_MODE_MULTIPLY: return @"multiply"; break;
        case SP_BLEND_MODE_SCREEN:   return @"screen";   break;
        case SP_BLEND_MODE_ERASE:    return @"erase";    break;
        default:                     return @"unknown";  break;
    }
}

// --- Class implementation ------------------------------------------------------------------------

@implementation SPBlendMode

- (id)init
{
    return nil;
}

// OpenGL blend factors are either 0, 1, or something between 0x0300 and 0x0308.
// We can use this to encode 4 blend factors in a single unsigned integer.

+ (uint)encodeBlendModeWithSourceFactor:(uint)sFactor destFactor:(uint)dFactor
                        sourceFactorPMA:(uint)sFactorPMA destFactorPMA:(uint)dFactorPMA
{
    return ((encodeFactor(sFactor))    << 24) |
           ((encodeFactor(dFactor))    << 16) |
           ((encodeFactor(sFactorPMA)) <<  8) |
           ( encodeFactor(dFactorPMA));
}

+ (void)decodeBlendMode:(uint)blendMode premultipliedAlpha:(BOOL)pma
       intoSourceFactor:(uint *)sFactor destFactor:(uint *)dFactor
{
    if (pma)
    {
        *sFactor = decodeFactor((blendMode & 0x0000ff00) >> 8);
        *dFactor = decodeFactor( blendMode & 0x000000ff);
    }
    else
    {
        *sFactor = decodeFactor((blendMode & 0xff000000) >> 24);
        *dFactor = decodeFactor((blendMode & 0x00ff0000) >> 16);
    }
}

+ (void)applyBlendFactorsForBlendMode:(uint)blendMode premultipliedAlpha:(BOOL)pma
{
    uint srcFactor, dstFactor;
    
    [self decodeBlendMode:blendMode premultipliedAlpha:pma intoSourceFactor:&srcFactor
               destFactor:&dstFactor];
    
    glBlendFunc(srcFactor, dstFactor);
}

+ (NSString *)describeBlendMode:(uint)blendMode
{
    return getNameOfMode(blendMode);
}

@end
