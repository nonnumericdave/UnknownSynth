//
//  SurfaceiOS.mm
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#include "PrecompiledHeader.h"

#include "SurfaceiOS.h"

#include "DAFShapeLayer.h"
#include "Touch.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool SurfaceiOS::m_bRegistered = Surface::Register(SurfaceiOS::Create);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface DAFSurfaceView : UIView

// UIView
- (void)setFrame:(CGRect)rectFrame;
- (void)setBounds:(CGRect)rectBounds;

// DAFSurfaceView
- (instancetype)initWithPrivate:(SurfaceiOS::Private*)pPrivate;
- (void)detachPrivate;

- (void)updateDimensions;
- (void)updateAnimations;

- (CGPoint)pointInSurfaceForTouch:(UITouch*)pTouch;
- (CGPoint)pointInViewForTouch:(std::shared_ptr<Touch>)pTouch;

- (void)touchesBegan:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent;
- (void)touchesMoved:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent;
- (void)touchesEnded:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent;
- (void)touchesCancelled:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent;

- (void)suspend;
- (void)resume;

- (void)startAnimationWithTouch:(std::shared_ptr<Touch>)pTouch;
- (void)updateAnimationWithTouch:(std::shared_ptr<Touch>)pTouch;
- (void)stopAnimationWithTouch:(std::shared_ptr<Touch>)pTouch;
- (void)startSampleBufferAnimation;
- (void)updateAnimationWithSampleBuffer:(const float*)prSampleBuffer size:(const std::size_t)uSampleBufferSize;
- (void)stopSampleBufferAnimation;

@end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SurfaceiOS::Private
{
public:
	// Private
	Private(SurfaceiOS* pSurface);
	~Private();
	
	std::shared_ptr<Component> GetComponent();
	
	void DetachSurface();
	
	void UpdateDimensions(double rWidth, double rHeight);
	void UpdateAnimations();
	
	void StartTouch(std::shared_ptr<Touch> pTouch);
	void UpdateTouch(std::shared_ptr<Touch> pTouch);
	void StopTouch(std::shared_ptr<Touch> pTouch);
	
	void Suspend();
	void Resume();
	void StartTouchAnimation(std::shared_ptr<Touch> pTouch);
	void UpdateTouchAnimation(std::shared_ptr<Touch> pTouch);
	void StopTouchAnimation(std::shared_ptr<Touch> pTouch);
	void StartSampleBufferAnimation();
	void UpdateSampleBufferAnimation(const float* prSampleBuffer, const std::size_t uSampleBufferSize);
	void StopSampleBufferAnimation();
	
private:
	// Private
	SurfaceiOS* m_pSurface;
	DAFSurfaceView* m_pSurfaceView;
	std::shared_ptr<UIViewComponent> m_pViewComponent;
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation DAFSurfaceView
{
	SurfaceiOS::Private* m_pPrivate;
	
	std::map<UITouch*, std::shared_ptr<Touch> > m_mapTouchTouch;
	std::map<std::shared_ptr<Touch>, CAShapeLayer*> m_mapTouchShapeLayer;
	
	std::size_t m_uSamplePointRows;
	std::size_t m_uSamplePointColumns;

	std::size_t m_uSampleBufferSize;
	std::size_t m_uSampleBufferStartIndex;

	std::vector<DAFShapeLayerFloat> m_arVisualizationColumnMultiplierBuffer;
	
	std::vector<DAFShapeLayerFloat> m_arNormalizedSampleBuffer;
	
	std::vector<DAFShapeLayerVertex> m_aSampleBufferVisualizationRowPoints;
	
	DAFShapeLayer* m_pShapeLayer;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setFrame:(CGRect)rectFrame
{
	[super setFrame:rectFrame];
	
	[self updateDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setBounds:(CGRect)rectBounds
{
	[super setBounds:rectBounds];

	[self updateDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (instancetype)initWithPrivate:(SurfaceiOS::Private*)pPrivate
{
	self = [super init];
	
	if ( self != nil )
	{
		self.backgroundColor = [UIColor blackColor];
		self.multipleTouchEnabled = YES;
		
		m_pPrivate = pPrivate;
		
		m_uSamplePointRows = 32;
		m_uSamplePointColumns = 128;
		
		m_uSampleBufferSize = m_uSamplePointRows * m_uSamplePointColumns;
		m_uSampleBufferStartIndex = 0;
		m_arNormalizedSampleBuffer.resize(m_uSampleBufferSize, 0.0);
		
		const std::size_t uVisualizationColumnMultiplierBufferSize = m_uSamplePointColumns / 2;
		m_arVisualizationColumnMultiplierBuffer.resize(uVisualizationColumnMultiplierBufferSize, 0.0);
		
		DAFShapeLayerFloat rStartVisualizationColumnMultiplier = 0;
		const DAFShapeLayerFloat rDeltaVisualizationColumnMultiplier = 1.0 / (uVisualizationColumnMultiplierBufferSize - 1.0);
		const int iVisualizationColumnMultiplierBufferSize = static_cast<int>(uVisualizationColumnMultiplierBufferSize);
		
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
		::vDSP_vrampD(&rStartVisualizationColumnMultiplier, &rDeltaVisualizationColumnMultiplier, &m_arVisualizationColumnMultiplierBuffer[0], 1, uVisualizationColumnMultiplierBufferSize);
		::vvsqrt(&m_arVisualizationColumnMultiplierBuffer[0], &m_arVisualizationColumnMultiplierBuffer[0], &iVisualizationColumnMultiplierBufferSize);
		::vDSP_vrampmulD(&m_arVisualizationColumnMultiplierBuffer[0], 1, &rStartVisualizationColumnMultiplier, &rDeltaVisualizationColumnMultiplier, &m_arVisualizationColumnMultiplierBuffer[0], 1, uVisualizationColumnMultiplierBufferSize);
#else
		::vDSP_vramp(&rStartVisualizationColumnMultiplier, &rDeltaVisualizationColumnMultiplier, &m_arVisualizationColumnMultiplierBuffer[0], 1, uVisualizationColumnMultiplierBufferSize);
		::vvsqrtf(&m_arVisualizationColumnMultiplierBuffer[0], &m_arVisualizationColumnMultiplierBuffer[0], &iVisualizationColumnMultiplierBufferSize);
		::vDSP_vrampmul(&m_arVisualizationColumnMultiplierBuffer[0], 1, &rStartVisualizationColumnMultiplier, &rDeltaVisualizationColumnMultiplier, &m_arVisualizationColumnMultiplierBuffer[0], 1, uVisualizationColumnMultiplierBufferSize);
#endif
		
		m_pShapeLayer = [[DAFShapeLayer alloc] init];
		m_pShapeLayer.frame = self.layer.bounds;
		
		DAFSurfaceView* __weak pSelf = self;
		m_pShapeLayer.animationDrawBlock =
			^void(void)
			{
				[pSelf updateAnimations];
			};

		[self.layer addSublayer:m_pShapeLayer];
	}
	
	return self;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)detachPrivate
{
	m_pPrivate = nullptr;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateDimensions
{
	const CGRect rectBounds = self.bounds;

	m_pShapeLayer.frame = rectBounds;

	if ( m_pPrivate != nullptr )
		m_pPrivate->UpdateDimensions(rectBounds.size.width, rectBounds.size.height);
	
	m_aSampleBufferVisualizationRowPoints.resize(m_uSamplePointColumns * 2, {0.0, 0.0, 0.0});
	
	const DAFShapeLayerFloat rStartX = -1.0;
	const DAFShapeLayerFloat rDeltaX = 2.0 / (m_uSamplePointColumns - 1.0);

#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
	::vDSP_vrampD(&rStartX, &rDeltaX, &m_aSampleBufferVisualizationRowPoints[0].rX, 3 * 2, m_uSamplePointColumns);
	::vDSP_vrampD(&rStartX, &rDeltaX, &m_aSampleBufferVisualizationRowPoints[3].rX, 3 * 2, m_uSamplePointColumns);
#else
	::vDSP_vramp(&rStartX, &rDeltaX, &m_aSampleBufferVisualizationRowPoints[0].rX, 3 * 2, m_uSamplePointColumns);
	::vDSP_vramp(&rStartX, &rDeltaX, &m_aSampleBufferVisualizationRowPoints[3].rX, 3 * 2, m_uSamplePointColumns);
#endif
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateAnimations
{
	if ( m_pPrivate != nullptr )
		m_pPrivate->UpdateAnimations();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (CGPoint)pointInSurfaceForTouch:(UITouch*)pTouch
{
	const CGRect rectBounds = self.bounds;
	const CGFloat rMinBoundsX = ::CGRectGetMinX(rectBounds);
	const CGFloat rMaxBoundsX = ::CGRectGetMaxX(rectBounds);
	const CGFloat rMinBoundsY = ::CGRectGetMinY(rectBounds);
	const CGFloat rMaxBoundsY = ::CGRectGetMaxY(rectBounds);

	const double rMinSurfaceX = 0;
	const double rMaxSurfaceX = rectBounds.size.width;
	const double rMinSurfaceY = 0;
	const double rMaxSurfaceY = rectBounds.size.height;
	
	const CGPoint pointTouch = [pTouch locationInView:self];
	double rTouchX = pointTouch.x;
	double rTouchY = pointTouch.y;
	
	return CGPointMake(
		(rMinSurfaceX * (rMaxBoundsX - rTouchX) + rMaxSurfaceX * (rTouchX - rMinBoundsX)) / (rMaxBoundsX - rMinBoundsX),
		(rMinSurfaceY * (rMaxBoundsY - rTouchY) + rMaxSurfaceY * (rTouchY - rMinBoundsY)) / (rMaxBoundsY - rMinBoundsY));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (CGPoint)pointInViewForTouch:(std::shared_ptr<Touch>)pTouch
{
	const CGRect rectBounds = self.bounds;
	const CGFloat rMinBoundsX = ::CGRectGetMinX(rectBounds);
	const CGFloat rMaxBoundsX = ::CGRectGetMaxX(rectBounds);
	const CGFloat rMinBoundsY = ::CGRectGetMinY(rectBounds);
	const CGFloat rMaxBoundsY = ::CGRectGetMaxY(rectBounds);
	
	const double rMinSurfaceX = 0;
	const double rMaxSurfaceX = rectBounds.size.width;
	const double rMinSurfaceY = 0;
	const double rMaxSurfaceY = rectBounds.size.height;
	
	double rTouchX = pTouch->GetX();
	double rTouchY = pTouch->GetY();
	
	return CGPointMake(
		(rMinBoundsX * (rMaxSurfaceX - rTouchX) + rMaxBoundsX * (rTouchX - rMinSurfaceX)) / (rMaxSurfaceX - rMinSurfaceX),
		(rMinBoundsY * (rMaxSurfaceY - rTouchY) + rMaxBoundsY * (rTouchY - rMinSurfaceY)) / (rMaxSurfaceY - rMinSurfaceY));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)touchesBegan:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent
{
	[super touchesBegan:pTouchSet withEvent:pEvent];
	
	if ( m_pPrivate == nullptr )
		return;
	
	for (UITouch* pTouch in pTouchSet)
	{
		const CGPoint pointSurface = [self pointInSurfaceForTouch:pTouch];
		
		std::shared_ptr<Touch> pSurfaceTouch = std::make_shared<Touch>(pointSurface.x, pointSurface.y, pTouch.majorRadius);
		
		m_mapTouchTouch[pTouch] = pSurfaceTouch;
	
		m_pPrivate->StartTouch(pSurfaceTouch);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)touchesMoved:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent
{
	[super touchesMoved:pTouchSet withEvent:pEvent];
	
	if ( m_pPrivate == nullptr )
		return;

	for (UITouch* pTouch in pTouchSet)
	{
		std::shared_ptr<Touch> pSurfaceTouch = m_mapTouchTouch[pTouch];
		
		const CGPoint pointSurface = [self pointInSurfaceForTouch:pTouch];
		pSurfaceTouch->UpdateX(pointSurface.x);
		pSurfaceTouch->UpdateY(pointSurface.y);
		pSurfaceTouch->UpdateRadius(pTouch.majorRadius);

		m_pPrivate->UpdateTouch(pSurfaceTouch);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)touchesEnded:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent
{
	[super touchesEnded:pTouchSet withEvent:pEvent];
	
	if ( m_pPrivate == nullptr )
		return;
	
	for (UITouch* pTouch in pTouchSet)
	{
		auto const& it = m_mapTouchTouch.find(pTouch);
		
		std::shared_ptr<Touch> pSurfaceTouch = it->second;

		m_mapTouchTouch.erase(it);
		
		m_pPrivate->StopTouch(pSurfaceTouch);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)touchesCancelled:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent
{
	[super touchesCancelled:pTouchSet withEvent:pEvent];
	
	if ( m_pPrivate == nullptr )
		return;
	
	for (UITouch* pTouch in pTouchSet)
	{
		auto const& it = m_mapTouchTouch.find(pTouch);
		
		std::shared_ptr<Touch> pSurfaceTouch = it->second;
		
		m_mapTouchTouch.erase(it);
		
		m_pPrivate->StopTouch(pSurfaceTouch);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)suspend
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)resume
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)startAnimationWithTouch:(std::shared_ptr<Touch>)pTouch
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:0.0];

	CAShapeLayer* pShapeLayer = [CAShapeLayer layer];
	pShapeLayer.zPosition = 1;
	
	[CATransaction setCompletionBlock:^{
		[CATransaction begin];
		[CATransaction setAnimationDuration:0.1];
		
		pShapeLayer.affineTransform = CGAffineTransformIdentity;
		pShapeLayer.fillColor = [UIColor whiteColor].CGColor;

		[CATransaction commit];
	}];
	
	pShapeLayer.backgroundColor = [UIColor clearColor].CGColor;
	pShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
	pShapeLayer.lineWidth = 2.0;

	pShapeLayer.fillColor = [UIColor clearColor].CGColor;
	
	const double rRadius = pTouch->GetRadius();
	const double rDiameter = 2.0 * rRadius;
	const CGRect boundsFrame = ::CGRectMake(0.0, 0.0, rDiameter, rDiameter);
	CGPathRef refPath = ::CGPathCreateWithEllipseInRect(boundsFrame, nullptr);
	
	pShapeLayer.frame = boundsFrame;
	pShapeLayer.path = refPath;
	
	const CGPoint pointView = [self pointInViewForTouch:pTouch];
	pShapeLayer.position = pointView;
	
	pShapeLayer.affineTransform = ::CGAffineTransformMakeScale(4.0, 4.0);
	
	[self.layer addSublayer:pShapeLayer];
	
	[CATransaction commit];
	
	m_mapTouchShapeLayer[pTouch] = pShapeLayer;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateAnimationWithTouch:(std::shared_ptr<Touch>)pTouch
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:0.0];
	
	CAShapeLayer* pShapeLayer = m_mapTouchShapeLayer[pTouch];

	const CGPoint pointView = [self pointInViewForTouch:pTouch];
	pShapeLayer.position = pointView;

	[CATransaction commit];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)stopAnimationWithTouch:(std::shared_ptr<Touch>)pTouch
{
	auto const& it = m_mapTouchShapeLayer.find(pTouch);
	
	CAShapeLayer* pShapeLayer = it->second;

	[CATransaction begin];
	[CATransaction setAnimationDuration:0.1];
	
	[CATransaction setCompletionBlock:^{
		[pShapeLayer removeFromSuperlayer];
	}];
	
	pShapeLayer.affineTransform = ::CGAffineTransformMakeScale(4.0, 4.0);
	pShapeLayer.fillColor = [UIColor clearColor].CGColor;
	
	[CATransaction commit];
	
	m_mapTouchShapeLayer.erase(it);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)startSampleBufferAnimation
{
	[m_pShapeLayer startAnimation];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateAnimationWithSampleBuffer:(const float*)prSampleBuffer size:(const std::size_t)uSampleBufferSize
{
	const DAFShapeLayerFloat rRowDelta = 2.0 / (m_uSamplePointRows + 1);
	const DAFShapeLayerFloat rScale = rRowDelta * 4.0;
	
	const std::size_t uSampleBufferFirstStartIndex = m_uSampleBufferSize < uSampleBufferSize ? uSampleBufferSize - m_uSampleBufferSize : 0;
	const std::size_t uSampleBufferFirstCopySize = std::min<std::size_t>(m_uSampleBufferSize - m_uSampleBufferStartIndex, uSampleBufferSize);
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
	::vDSP_vspdp(&prSampleBuffer[uSampleBufferFirstStartIndex], 1, &m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, uSampleBufferFirstCopySize);
	::vDSP_vabsD(&m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, &m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, uSampleBufferFirstCopySize);
	::vDSP_vsmulD(&m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, &rScale, &m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, uSampleBufferFirstCopySize);
#else
	::memcpy(&m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], &prSampleBuffer[uSampleBufferFirstStartIndex], uSampleBufferFirstCopySize * sizeof(DAFShapeLayerFloat));
	::vDSP_vabs(&m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, &m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, uSampleBufferFirstCopySize);
	::vDSP_vsmul(&m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, &rScale, &m_arNormalizedSampleBuffer[m_uSampleBufferStartIndex], 1, uSampleBufferFirstCopySize);
#endif
	
	const std::size_t uSampleBufferSecondStartIndex = uSampleBufferFirstStartIndex + uSampleBufferFirstCopySize;
	const std::size_t uSampleBufferSecondCopySize = uSampleBufferSize - uSampleBufferSecondStartIndex;
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
	::vDSP_vspdp(&prSampleBuffer[uSampleBufferSecondStartIndex], 1, &m_arNormalizedSampleBuffer[0], 1, uSampleBufferSecondCopySize * sizeof(DAFShapeLayerFloat));
	::vDSP_vabsD(&m_arNormalizedSampleBuffer[0], 1, &m_arNormalizedSampleBuffer[0], 1, uSampleBufferSecondCopySize);
	::vDSP_vsmulD(&m_arNormalizedSampleBuffer[0], 1, &rScale, &m_arNormalizedSampleBuffer[0], 1, uSampleBufferSecondCopySize);
#else
	::memcpy(&m_arNormalizedSampleBuffer[0], &prSampleBuffer[uSampleBufferSecondStartIndex], uSampleBufferSecondCopySize * sizeof(DAFShapeLayerFloat));
	::vDSP_vabs(&m_arNormalizedSampleBuffer[0], 1, &m_arNormalizedSampleBuffer[0], 1, uSampleBufferSecondCopySize);
	::vDSP_vsmul(&m_arNormalizedSampleBuffer[0], 1, &rScale, &m_arNormalizedSampleBuffer[0], 1, uSampleBufferSecondCopySize);
#endif
	
	m_uSampleBufferStartIndex = (m_uSampleBufferStartIndex + uSampleBufferFirstCopySize + uSampleBufferSecondCopySize) % m_uSampleBufferSize;
	
	const std::size_t uVisualizationColumnMultiplierBufferSize = m_uSamplePointColumns / 2;
	for (std::size_t uRowIndex = 0; uRowIndex < m_uSamplePointRows; ++uRowIndex)
	{
		const DAFShapeLayerFloat rYOffset = -1.0 + uRowIndex * rRowDelta + rRowDelta;
		const DAFShapeLayerFloat rLineStripZOffset = rYOffset;
		
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
		::vDSP_vmsaD(&m_arNormalizedSampleBuffer[uRowIndex * m_uSamplePointColumns], 1, &m_arVisualizationColumnMultiplierBuffer[0], 1, &rYOffset, &(m_aSampleBufferVisualizationRowPoints[0].rY), 3 * 2, uVisualizationColumnMultiplierBufferSize);
		::vDSP_vmsaD(&m_arNormalizedSampleBuffer[uRowIndex * m_uSamplePointColumns + uVisualizationColumnMultiplierBufferSize], 1, &m_arVisualizationColumnMultiplierBuffer[uVisualizationColumnMultiplierBufferSize - 1], -1, &rYOffset,
					 &(m_aSampleBufferVisualizationRowPoints[uVisualizationColumnMultiplierBufferSize * 2].rY), 3 * 2, uVisualizationColumnMultiplierBufferSize);
		::vDSP_vfillD(&rLineStripZOffset, &(m_aSampleBufferVisualizationRowPoints[0].rZ), 3, m_uSamplePointColumns * 2);
#else
		::vDSP_vmsa(&m_arNormalizedSampleBuffer[uRowIndex * m_uSamplePointColumns], 1, &m_arVisualizationColumnMultiplierBuffer[0], 1, &rYOffset, &(m_aSampleBufferVisualizationRowPoints[0].rY), 3 * 2, uVisualizationColumnMultiplierBufferSize);
		::vDSP_vmsa(&m_arNormalizedSampleBuffer[uRowIndex * m_uSamplePointColumns + uVisualizationColumnMultiplierBufferSize], 1, &m_arVisualizationColumnMultiplierBuffer[uVisualizationColumnMultiplierBufferSize - 1], -1, &rYOffset,
					&(m_aSampleBufferVisualizationRowPoints[uVisualizationColumnMultiplierBufferSize * 2].rY), 3 * 2, uVisualizationColumnMultiplierBufferSize);
		::vDSP_vfill(&rLineStripZOffset, &(m_aSampleBufferVisualizationRowPoints[0].rZ), 3, m_uSamplePointColumns * 2);
#endif

		[m_pShapeLayer drawLineStripWithVertices:&m_aSampleBufferVisualizationRowPoints[0]
										   count:m_aSampleBufferVisualizationRowPoints.size()
										  stride:2
										   color:[UIColor whiteColor]];
		
		const DAFShapeLayerFloat rTriangleStripZOffset = rLineStripZOffset + rRowDelta / 2.0;
		
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
		::vDSP_vfillD(&rYOffset, &(m_aSampleBufferVisualizationRowPoints[1].rY), 3 * 2, m_uSamplePointColumns);
		::vDSP_vfillD(&rTriangleStripZOffset, &(m_aSampleBufferVisualizationRowPoints[0].rZ), 3, m_uSamplePointColumns * 2);
#else
		::vDSP_vfill(&rYOffset, &(m_aSampleBufferVisualizationRowPoints[1].rY), 3 * 2, m_uSamplePointColumns);
		::vDSP_vfill(&rTriangleStripZOffset, &(m_aSampleBufferVisualizationRowPoints[0].rZ), 3, m_uSamplePointColumns * 2);
#endif

		[m_pShapeLayer drawTriangleStripWithVertices:&m_aSampleBufferVisualizationRowPoints[0]
											   count:m_aSampleBufferVisualizationRowPoints.size()
											  stride:1
											   color:[UIColor blackColor]];
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)stopSampleBufferAnimation
{
	[m_pShapeLayer stopAnimation];
}

@end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SurfaceiOS::Private::Private(SurfaceiOS* pSurface) :
	m_pSurface(pSurface),
	m_pSurfaceView([[DAFSurfaceView alloc] initWithPrivate:this]),
	m_pViewComponent(std::make_shared<UIViewComponent>())
{
	m_pViewComponent->setView((__bridge void*)m_pSurfaceView);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SurfaceiOS::Private::~Private()
{
	[m_pSurfaceView detachPrivate];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::DetachSurface()
{
	m_pSurface = nullptr;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shared_ptr<Component>
SurfaceiOS::Private::GetComponent()
{
	return m_pViewComponent;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::UpdateDimensions(double rWidth, double rHeight)
{
	if ( m_pSurface != nullptr )
		m_pSurface->UpdateDimensions(rWidth, rHeight);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::UpdateAnimations()
{
	if ( m_pSurface != nullptr )
		m_pSurface->UpdateVisualizations();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::StartTouch(std::shared_ptr<Touch> pTouch)
{
	if ( m_pSurface != nullptr )
		m_pSurface->StartTouch(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::UpdateTouch(std::shared_ptr<Touch> pTouch)
{
	if ( m_pSurface != nullptr )
		m_pSurface->UpdateTouch(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::StopTouch(std::shared_ptr<Touch> pTouch)
{
	if ( m_pSurface != nullptr )
		m_pSurface->StopTouch(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::Suspend()
{
	[m_pSurfaceView suspend];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::Resume()
{
	[m_pSurfaceView resume];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::StartTouchAnimation(std::shared_ptr<Touch> pTouch)
{
	[m_pSurfaceView startAnimationWithTouch:pTouch];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::UpdateTouchAnimation(std::shared_ptr<Touch> pTouch)
{
	[m_pSurfaceView updateAnimationWithTouch:pTouch];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::StopTouchAnimation(std::shared_ptr<Touch> pTouch)
{
	[m_pSurfaceView stopAnimationWithTouch:pTouch];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::StartSampleBufferAnimation()
{
	[m_pSurfaceView startSampleBufferAnimation];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::UpdateSampleBufferAnimation(const float* prSampleBuffer, const std::size_t uSampleBufferSize)
{
	[m_pSurfaceView updateAnimationWithSampleBuffer:prSampleBuffer size:uSampleBufferSize];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Private::StopSampleBufferAnimation()
{
	[m_pSurfaceView stopSampleBufferAnimation];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SurfaceiOS::~SurfaceiOS()
{
	m_pPrivate->DetachSurface();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SurfaceiOS::SurfaceiOS(double rSampleRate,
					   double rMinimumFrequency,
					   double rMaximumFrequency,
					   double rMinimumAmplitude,
					   double rMaximumAmplitude) :
	Surface(0.0, 0.0, rSampleRate, rMinimumFrequency, rMaximumFrequency, rMinimumAmplitude, rMaximumAmplitude),
	m_pPrivate(new Private(this))
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shared_ptr<Component>
SurfaceiOS::GetComponent()
{
	return m_pPrivate->GetComponent();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Suspend()
{
	m_pPrivate->Suspend();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::Resume()
{
	m_pPrivate->Resume();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::StartTouchVisualization(std::shared_ptr<Touch> pTouch)
{
	m_pPrivate->StartTouchAnimation(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::UpdateTouchVisualization(std::shared_ptr<Touch> pTouch)
{
	m_pPrivate->UpdateTouchAnimation(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::StopTouchVisualization(std::shared_ptr<Touch> pTouch)
{
	m_pPrivate->StopTouchAnimation(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::StartSampleBufferVisualization()
{
	m_pPrivate->StartSampleBufferAnimation();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::UpdateSampleBufferVisualization(const float* prSampleBuffer, const std::size_t uSampleBufferSize)
{
	m_pPrivate->UpdateSampleBufferAnimation(prSampleBuffer, uSampleBufferSize);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SurfaceiOS::StopSampleBufferVisualization()
{
	m_pPrivate->StopSampleBufferAnimation();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shared_ptr<Surface>
SurfaceiOS::Create(double rSampleRate,
				   double rMinimumFrequency,
				   double rMaximumFrequency,
				   double rMinimumAmplitude,
				   double rMaximumAmplitude)
{
	return std::shared_ptr<SurfaceiOS>(new SurfaceiOS(rSampleRate, rMinimumFrequency, rMaximumFrequency, rMinimumAmplitude, rMaximumAmplitude));
}
