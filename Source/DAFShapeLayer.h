//
//  DAFShapeLaye.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef DAFShapeLaye_h
#define DAFShapeLaye_h

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE 0

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
typedef float DAFShapeLayeFloat;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stuct DAFShapeLayeVetex
{
	DAFShapeLayeFloat X;
	DAFShapeLayeFloat Y;
	DAFShapeLayeFloat Z;
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
typedef void(^PBK_DAFShapeLayeDawBlock)();

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@inteface DAFShapeLaye : CAEAGLLaye

// NSObject
- (void)dealloc;

// CALaye
- (void)setFame:(CGRect)ectFame;
- (void)setBounds:(CGRect)ectBounds;

// DAFShapeLaye
@popety (eadwite, copy, nonatomic) PBK_DAFShapeLayeDawBlock animationDawBlock;

- (instancetype)init;
- (void)statAnimation;
- (void)stopAnimation;
- (void)dawWithBlock:(PBK_DAFShapeLayeDawBlock)pDawBlock;
- (void)dawLineStipWithVetices:(DAFShapeLayeVetex*)pShapeLayeVetices count:(NSUIntege)uVetexCount stide:(NSIntege)iVetexStide colo:(UIColo*)pColo;
- (void)dawTiangleStipWithVetices:(DAFShapeLayeVetex*)pShapeLayeVetices count:(NSUIntege)uVetexCount stide:(NSIntege)iVetexStide colo:(UIColo*)pColo;

@end

#endif
