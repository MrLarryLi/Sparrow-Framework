//
//  SPButton.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.07.09.
//  Copyright 2011-2015 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SparrowBase.h>
#import <Sparrow/SPDisplayObjectContainer.h>

NS_ASSUME_NONNULL_BEGIN

@class SPSprite;
@class SPTexture;

/// Values for the states of a button object.
typedef NS_ENUM(NSInteger, SPButtonState)
{
    /// The button's default state.
    SPButtonStateUp,
    /// The button is pressed.
    SPButtonStateDown,
    /// The button was disabled altogether.
    SPButtonStateDisabled,
};

/** ------------------------------------------------------------------------------------------------

 An SPButton is a simple button composed of an image and, optionally, text.
 
 You can pass a texture for up- and downstate of the button. If you do not provide a down state,
 the button is simply scaled a little when it is touched.
 
 In addition, you can overlay a text on the button. To customize the text, almost the same options
 as those of SPTextField are provided. In addition, you can move the text to a certain position
 with the help of the `textBounds` property.
 
 To react on touches on a button, there is special event type: `SPEventTypeTriggered`. Use
 this event instead of normal touch events - that way, the button will behave just like standard
 iOS interface buttons.
 
------------------------------------------------------------------------------------------------- */

@interface SPButton : SPDisplayObjectContainer

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a button with textures for up-, down-, over- and disabled-state. _Designated Initializer_.
- (instancetype)initWithUpState:(SPTexture *)upState downState:(nullable SPTexture *)downState disabledState:(nullable SPTexture *)disabledState;

/// Initializes a button with textures for up- and down-state.
- (instancetype)initWithUpState:(SPTexture *)upState downState:(nullable SPTexture *)downState;

/// Initializes a button with an up state texture and text.
- (instancetype)initWithUpState:(SPTexture *)upState text:(NSString *)text;

/// Initializes a button only with an up state.
- (instancetype)initWithUpState:(SPTexture *)upState;

/// Factory method.
+ (instancetype)buttonWithUpState:(SPTexture *)upState downState:(nullable SPTexture *)downState;

/// Factory method.
+ (instancetype)buttonWithUpState:(SPTexture *)upState text:(NSString *)text;

/// Factory method.
+ (instancetype)buttonWithUpState:(SPTexture *)upState;

/// -------------
/// @name Methods
/// -------------

/// Readjusts the dimensions of the button according to its current state texture.
/// Call this method to synchronize button and texture size after assigning a texture
/// with a different size. Per default, this method also resets the bounds of the
/// button's text.
- (void)readjustSize;

/// Readjusts the dimensions of the button according to its current state texture.
/// Call this method to synchronize button and texture size after assigning a texture
/// with a different size. Optionally resets the text bounds of the button's text.
- (void)readjustSize:(BOOL)resetTextBounds;

/// ----------------
/// @name Properties
/// ----------------

/// The current state of the button.
@property (nonatomic, assign) SPButtonState state;

/// The scale factor of the button on touch. Per default, a button with a down state texture won't scale.
@property (nonatomic, assign) float scaleWhenDown;

/// The alpha value of the button on touch. Default: 1.0
@property (nonatomic, assign) float alphaWhenDown;

/// The alpha value of the button when it is disabled. Default: 0.5
@property (nonatomic, assign) float alphaWhenDisabled;

/// Indicates if the button can be triggered.
@property (nonatomic, assign) BOOL  enabled;

/// The text that is displayed on the button.
@property (nonatomic, copy) NSString *text;

/// The name of the font displayed on the button. May be a system font or a registered bitmap font.
@property (nonatomic, copy) NSString *fontName;

/// The size of the font.
@property (nonatomic, assign) float fontSize;

/// The color of the font.
@property (nonatomic, assign) uint fontColor;

/// Indicates if the font should be bold.
@property (nonatomic, assign) BOOL fontBold;

/// The texture that is displayed when the button is not being touched.
@property (nonatomic, strong) SPTexture *upState;

/// The texture that is displayed while the button is touched.
@property (nonatomic, strong, nullable) SPTexture *downState;

/// The texture that is displayed when the button is disabled.
@property (nonatomic, strong, nullable) SPTexture *disabledState;

/// The horizontal alignment of the text on the button.
@property (nonatomic, assign) SPHAlign textHAlign;

/// The vertical alignment of the text on the button.
@property (nonatomic, assign) SPVAlign textVAlign;

/// The bounds of the textfield on the button. Allows moving the text to a custom position.
@property (nonatomic, copy) SPRectangle *textBounds;

/// The color of the button's state image. Just like every image object, each pixel's
/// color is multiplied with this value.
@property (nonatomic, assign) uint color;

/// The overlay sprite is displayed on top of the button contents. It scales with the
/// button when pressed. Use it to add additional objects to the button (e.g. an icon).
@property (nonatomic, readonly) SPSprite *overlay;

@end

NS_ASSUME_NONNULL_END