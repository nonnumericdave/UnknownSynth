//
//  DAFShapeLayer.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef DAFShapeLayer_h
#define DAFShapeLayer_h

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE 0

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
typedef float DAFShapeLayerFloat;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
struct DAFShapeLayerVertex
{
	DAFShapeLayerFloat rX;
	DAFShapeLayerFloat rY;
	DAFShapeLayerFloat rZ;
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
typedef void(^PBK_DAFShapeLayerDrawBlock)();

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface DAFShapeLayer : CAEAGLLayer

// NSObject
- (void)dealloc;

// CALayer
- (void)setFrame:(CGRect)rectFrame;
- (void)setBounds:(CGRect)rectBounds;

// DAFShapeLayer
@property (readwrite, copy, nonatomic) PBK_DAFShapeLayerDrawBlock animationDrawBlock;

- (instancetype)init;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawWithBlock:(PBK_DAFShapeLayerDrawBlock)pDrawBlock;
- (void)drawLineStripWithVertices:(DAFShapeLayerVertex*)pShapeLayerVertices count:(NSUInteger)uVertexCount stride:(NSInteger)iVertexStride color:(UIColor*)pColor;
- (void)drawTriangleStripWithVertices:(DAFShapeLayerVertex*)pShapeLayerVertices count:(NSUInteger)uVertexCount stride:(NSInteger)iVertexStride color:(UIColor*)pColor;

@end

#endif
