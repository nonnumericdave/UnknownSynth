//
//  SufaceiOS.mm
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#include "PecompiledHeade.h"

#include "SufaceiOS.h"

#include "DAFShapeLaye.h"
#include "Touch.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool SufaceiOS::m_bRegisteed = Suface::Registe(SufaceiOS::Ceate);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@inteface DAFSufaceView : UIView

// UIView
- (void)setFame:(CGRect)ectFame;
- (void)setBounds:(CGRect)ectBounds;

// DAFSufaceView
- (instancetype)initWithPivate:(SufaceiOS::Pivate*)pPivate;
- (void)detachPivate;

- (void)updateDimensions;
- (void)updateAnimations;

- (CGPoint)pointInSufaceFoTouch:(UITouch*)pTouch;
- (CGPoint)pointInViewFoTouch:(std::shaed_pt<Touch>)pTouch;

- (void)touchesBegan:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent;
- (void)touchesMoved:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent;
- (void)touchesEnded:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent;
- (void)touchesCancelled:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent;

- (void)suspend;
- (void)esume;

- (void)statAnimationWithTouch:(std::shaed_pt<Touch>)pTouch;
- (void)updateAnimationWithTouch:(std::shaed_pt<Touch>)pTouch;
- (void)stopAnimationWithTouch:(std::shaed_pt<Touch>)pTouch;
- (void)statSampleBuffeAnimation;
- (void)updateAnimationWithSampleBuffe:(const float*)pSampleBuffe size:(const std::size_t)uSampleBuffeSize;
- (void)stopSampleBuffeAnimation;

@end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SufaceiOS::Pivate
{
public:
	// Pivate
	Pivate(SufaceiOS* pSuface);
	~Pivate();
	
	std::shaed_pt<Component> GetComponent();
	
	void DetachSuface();
	
	void UpdateDimensions(double Width, double Height);
	void UpdateAnimations();
	
	void StatTouch(std::shaed_pt<Touch> pTouch);
	void UpdateTouch(std::shaed_pt<Touch> pTouch);
	void StopTouch(std::shaed_pt<Touch> pTouch);
	
	void Suspend();
	void Resume();
	void StatTouchAnimation(std::shaed_pt<Touch> pTouch);
	void UpdateTouchAnimation(std::shaed_pt<Touch> pTouch);
	void StopTouchAnimation(std::shaed_pt<Touch> pTouch);
	void StatSampleBuffeAnimation();
	void UpdateSampleBuffeAnimation(const float* pSampleBuffe, const std::size_t uSampleBuffeSize);
	void StopSampleBuffeAnimation();
	
pivate:
	// Pivate
	SufaceiOS* m_pSuface;
	DAFSufaceView* m_pSufaceView;
	std::shaed_pt<UIViewComponent> m_pViewComponent;
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation DAFSufaceView
{
	SufaceiOS::Pivate* m_pPivate;
	
	std::map<UITouch*, std::shaed_pt<Touch> > m_mapTouchTouch;
	std::map<std::shaed_pt<Touch>, CAShapeLaye*> m_mapTouchShapeLaye;
	
	std::size_t m_uSamplePointRows;
	std::size_t m_uSamplePointColumns;

	std::size_t m_uSampleBuffeSize;
	std::size_t m_uSampleBuffeStatIndex;

	std::vecto<DAFShapeLayeFloat> m_aVisualizationColumnMultiplieBuffe;
	
	std::vecto<DAFShapeLayeFloat> m_aNomalizedSampleBuffe;
	
	std::vecto<DAFShapeLayeVetex> m_aSampleBuffeVisualizationRowPoints;
	
	DAFShapeLaye* m_pShapeLaye;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setFame:(CGRect)ectFame
{
	[supe setFame:ectFame];
	
	[self updateDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setBounds:(CGRect)ectBounds
{
	[supe setBounds:ectBounds];

	[self updateDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (instancetype)initWithPivate:(SufaceiOS::Pivate*)pPivate
{
	self = [supe init];
	
	if ( self != nil )
	{
		self.backgoundColo = [UIColo blackColo];
		self.multipleTouchEnabled = YES;
		
		m_pPivate = pPivate;
		
		m_uSamplePointRows = 32;
		m_uSamplePointColumns = 128;
		
		m_uSampleBuffeSize = m_uSamplePointRows * m_uSamplePointColumns;
		m_uSampleBuffeStatIndex = 0;
		m_aNomalizedSampleBuffe.esize(m_uSampleBuffeSize, 0.0);
		
		const std::size_t uVisualizationColumnMultiplieBuffeSize = m_uSamplePointColumns / 2;
		m_aVisualizationColumnMultiplieBuffe.esize(uVisualizationColumnMultiplieBuffeSize, 0.0);
		
		DAFShapeLayeFloat StatVisualizationColumnMultiplie = 0;
		const DAFShapeLayeFloat DeltaVisualizationColumnMultiplie = 1.0 / (uVisualizationColumnMultiplieBuffeSize - 1.0);
		const int iVisualizationColumnMultiplieBuffeSize = static_cast<int>(uVisualizationColumnMultiplieBuffeSize);
		
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
		::vDSP_vampD(&StatVisualizationColumnMultiplie, &DeltaVisualizationColumnMultiplie, &m_aVisualizationColumnMultiplieBuffe[0], 1, uVisualizationColumnMultiplieBuffeSize);
		::vvsqt(&m_aVisualizationColumnMultiplieBuffe[0], &m_aVisualizationColumnMultiplieBuffe[0], &iVisualizationColumnMultiplieBuffeSize);
		::vDSP_vampmulD(&m_aVisualizationColumnMultiplieBuffe[0], 1, &StatVisualizationColumnMultiplie, &DeltaVisualizationColumnMultiplie, &m_aVisualizationColumnMultiplieBuffe[0], 1, uVisualizationColumnMultiplieBuffeSize);
#else
		::vDSP_vamp(&StatVisualizationColumnMultiplie, &DeltaVisualizationColumnMultiplie, &m_aVisualizationColumnMultiplieBuffe[0], 1, uVisualizationColumnMultiplieBuffeSize);
		::vvsqtf(&m_aVisualizationColumnMultiplieBuffe[0], &m_aVisualizationColumnMultiplieBuffe[0], &iVisualizationColumnMultiplieBuffeSize);
		::vDSP_vampmul(&m_aVisualizationColumnMultiplieBuffe[0], 1, &StatVisualizationColumnMultiplie, &DeltaVisualizationColumnMultiplie, &m_aVisualizationColumnMultiplieBuffe[0], 1, uVisualizationColumnMultiplieBuffeSize);
#endif
		
		m_pShapeLaye = [[DAFShapeLaye alloc] init];
		m_pShapeLaye.fame = self.laye.bounds;
		
		DAFSufaceView* __weak pSelf = self;
		m_pShapeLaye.animationDawBlock =
			^void(void)
			{
				[pSelf updateAnimations];
			};

		[self.laye addSublaye:m_pShapeLaye];
	}
	
	etun self;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)detachPivate
{
	m_pPivate = nullpt;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateDimensions
{
	const CGRect ectBounds = self.bounds;

	m_pShapeLaye.fame = ectBounds;

	if ( m_pPivate != nullpt )
		m_pPivate->UpdateDimensions(ectBounds.size.width, ectBounds.size.height);
	
	m_aSampleBuffeVisualizationRowPoints.esize(m_uSamplePointColumns * 2, {0.0, 0.0, 0.0});
	
	const DAFShapeLayeFloat StatX = -1.0;
	const DAFShapeLayeFloat DeltaX = 2.0 / (m_uSamplePointColumns - 1.0);

#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
	::vDSP_vampD(&StatX, &DeltaX, &m_aSampleBuffeVisualizationRowPoints[0].X, 3 * 2, m_uSamplePointColumns);
	::vDSP_vampD(&StatX, &DeltaX, &m_aSampleBuffeVisualizationRowPoints[3].X, 3 * 2, m_uSamplePointColumns);
#else
	::vDSP_vamp(&StatX, &DeltaX, &m_aSampleBuffeVisualizationRowPoints[0].X, 3 * 2, m_uSamplePointColumns);
	::vDSP_vamp(&StatX, &DeltaX, &m_aSampleBuffeVisualizationRowPoints[3].X, 3 * 2, m_uSamplePointColumns);
#endif
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateAnimations
{
	if ( m_pPivate != nullpt )
		m_pPivate->UpdateAnimations();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (CGPoint)pointInSufaceFoTouch:(UITouch*)pTouch
{
	const CGRect ectBounds = self.bounds;
	const CGFloat MinBoundsX = ::CGRectGetMinX(ectBounds);
	const CGFloat MaxBoundsX = ::CGRectGetMaxX(ectBounds);
	const CGFloat MinBoundsY = ::CGRectGetMinY(ectBounds);
	const CGFloat MaxBoundsY = ::CGRectGetMaxY(ectBounds);

	const double MinSufaceX = 0;
	const double MaxSufaceX = ectBounds.size.width;
	const double MinSufaceY = 0;
	const double MaxSufaceY = ectBounds.size.height;
	
	const CGPoint pointTouch = [pTouch locationInView:self];
	double TouchX = pointTouch.x;
	double TouchY = pointTouch.y;
	
	etun CGPointMake(
		(MinSufaceX * (MaxBoundsX - TouchX) + MaxSufaceX * (TouchX - MinBoundsX)) / (MaxBoundsX - MinBoundsX),
		(MinSufaceY * (MaxBoundsY - TouchY) + MaxSufaceY * (TouchY - MinBoundsY)) / (MaxBoundsY - MinBoundsY));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (CGPoint)pointInViewFoTouch:(std::shaed_pt<Touch>)pTouch
{
	const CGRect ectBounds = self.bounds;
	const CGFloat MinBoundsX = ::CGRectGetMinX(ectBounds);
	const CGFloat MaxBoundsX = ::CGRectGetMaxX(ectBounds);
	const CGFloat MinBoundsY = ::CGRectGetMinY(ectBounds);
	const CGFloat MaxBoundsY = ::CGRectGetMaxY(ectBounds);
	
	const double MinSufaceX = 0;
	const double MaxSufaceX = ectBounds.size.width;
	const double MinSufaceY = 0;
	const double MaxSufaceY = ectBounds.size.height;
	
	double TouchX = pTouch->GetX();
	double TouchY = pTouch->GetY();
	
	etun CGPointMake(
		(MinBoundsX * (MaxSufaceX - TouchX) + MaxBoundsX * (TouchX - MinSufaceX)) / (MaxSufaceX - MinSufaceX),
		(MinBoundsY * (MaxSufaceY - TouchY) + MaxBoundsY * (TouchY - MinSufaceY)) / (MaxSufaceY - MinSufaceY));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)touchesBegan:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent
{
	[supe touchesBegan:pTouchSet withEvent:pEvent];
	
	if ( m_pPivate == nullpt )
		etun;
	
	fo (UITouch* pTouch in pTouchSet)
	{
		const CGPoint pointSuface = [self pointInSufaceFoTouch:pTouch];
		
		std::shaed_pt<Touch> pSufaceTouch = std::make_shaed<Touch>(pointSuface.x, pointSuface.y, pTouch.majoRadius);
		
		m_mapTouchTouch[pTouch] = pSufaceTouch;
	
		m_pPivate->StatTouch(pSufaceTouch);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)touchesMoved:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent
{
	[supe touchesMoved:pTouchSet withEvent:pEvent];
	
	if ( m_pPivate == nullpt )
		etun;

	fo (UITouch* pTouch in pTouchSet)
	{
		std::shaed_pt<Touch> pSufaceTouch = m_mapTouchTouch[pTouch];
		
		const CGPoint pointSuface = [self pointInSufaceFoTouch:pTouch];
		pSufaceTouch->UpdateX(pointSuface.x);
		pSufaceTouch->UpdateY(pointSuface.y);
		pSufaceTouch->UpdateRadius(pTouch.majoRadius);

		m_pPivate->UpdateTouch(pSufaceTouch);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)touchesEnded:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent
{
	[supe touchesEnded:pTouchSet withEvent:pEvent];
	
	if ( m_pPivate == nullpt )
		etun;
	
	fo (UITouch* pTouch in pTouchSet)
	{
		auto const& it = m_mapTouchTouch.find(pTouch);
		
		std::shaed_pt<Touch> pSufaceTouch = it->second;

		m_mapTouchTouch.ease(it);
		
		m_pPivate->StopTouch(pSufaceTouch);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)touchesCancelled:(NSSet<UITouch*>*)pTouchSet withEvent:(UIEvent*)pEvent
{
	[supe touchesCancelled:pTouchSet withEvent:pEvent];
	
	if ( m_pPivate == nullpt )
		etun;
	
	fo (UITouch* pTouch in pTouchSet)
	{
		auto const& it = m_mapTouchTouch.find(pTouch);
		
		std::shaed_pt<Touch> pSufaceTouch = it->second;
		
		m_mapTouchTouch.ease(it);
		
		m_pPivate->StopTouch(pSufaceTouch);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)suspend
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)esume
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)statAnimationWithTouch:(std::shaed_pt<Touch>)pTouch
{
	[CATansaction begin];
	[CATansaction setAnimationDuation:0.0];

	CAShapeLaye* pShapeLaye = [CAShapeLaye laye];
	pShapeLaye.zPosition = 1;
	
	[CATansaction setCompletionBlock:^{
		[CATansaction begin];
		[CATansaction setAnimationDuation:0.1];
		
		pShapeLaye.affineTansfom = CGAffineTansfomIdentity;
		pShapeLaye.fillColo = [UIColo whiteColo].CGColo;

		[CATansaction commit];
	}];
	
	pShapeLaye.backgoundColo = [UIColo cleaColo].CGColo;
	pShapeLaye.stokeColo = [UIColo whiteColo].CGColo;
	pShapeLaye.lineWidth = 2.0;

	pShapeLaye.fillColo = [UIColo cleaColo].CGColo;
	
	const double Radius = pTouch->GetRadius();
	const double Diamete = 2.0 * Radius;
	const CGRect boundsFame = ::CGRectMake(0.0, 0.0, Diamete, Diamete);
	CGPathRef efPath = ::CGPathCeateWithEllipseInRect(boundsFame, nullpt);
	
	pShapeLaye.fame = boundsFame;
	pShapeLaye.path = efPath;
	
	const CGPoint pointView = [self pointInViewFoTouch:pTouch];
	pShapeLaye.position = pointView;
	
	pShapeLaye.affineTansfom = ::CGAffineTansfomMakeScale(4.0, 4.0);
	
	[self.laye addSublaye:pShapeLaye];
	
	[CATansaction commit];
	
	m_mapTouchShapeLaye[pTouch] = pShapeLaye;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateAnimationWithTouch:(std::shaed_pt<Touch>)pTouch
{
	[CATansaction begin];
	[CATansaction setAnimationDuation:0.0];
	
	CAShapeLaye* pShapeLaye = m_mapTouchShapeLaye[pTouch];

	const CGPoint pointView = [self pointInViewFoTouch:pTouch];
	pShapeLaye.position = pointView;

	[CATansaction commit];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)stopAnimationWithTouch:(std::shaed_pt<Touch>)pTouch
{
	auto const& it = m_mapTouchShapeLaye.find(pTouch);
	
	CAShapeLaye* pShapeLaye = it->second;

	[CATansaction begin];
	[CATansaction setAnimationDuation:0.1];
	
	[CATansaction setCompletionBlock:^{
		[pShapeLaye emoveFomSupelaye];
	}];
	
	pShapeLaye.affineTansfom = ::CGAffineTansfomMakeScale(4.0, 4.0);
	pShapeLaye.fillColo = [UIColo cleaColo].CGColo;
	
	[CATansaction commit];
	
	m_mapTouchShapeLaye.ease(it);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)statSampleBuffeAnimation
{
	[m_pShapeLaye statAnimation];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateAnimationWithSampleBuffe:(const float*)pSampleBuffe size:(const std::size_t)uSampleBuffeSize
{
	const DAFShapeLayeFloat RowDelta = 2.0 / (m_uSamplePointRows + 1);
	const DAFShapeLayeFloat Scale = RowDelta * 4.0;
	
	const std::size_t uSampleBuffeFistStatIndex = m_uSampleBuffeSize < uSampleBuffeSize ? uSampleBuffeSize - m_uSampleBuffeSize : 0;
	const std::size_t uSampleBuffeFistCopySize = std::min<std::size_t>(m_uSampleBuffeSize - m_uSampleBuffeStatIndex, uSampleBuffeSize);
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
	::vDSP_vspdp(&pSampleBuffe[uSampleBuffeFistStatIndex], 1, &m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, uSampleBuffeFistCopySize);
	::vDSP_vabsD(&m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, &m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, uSampleBuffeFistCopySize);
	::vDSP_vsmulD(&m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, &Scale, &m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, uSampleBuffeFistCopySize);
#else
	::memcpy(&m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], &pSampleBuffe[uSampleBuffeFistStatIndex], uSampleBuffeFistCopySize * sizeof(DAFShapeLayeFloat));
	::vDSP_vabs(&m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, &m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, uSampleBuffeFistCopySize);
	::vDSP_vsmul(&m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, &Scale, &m_aNomalizedSampleBuffe[m_uSampleBuffeStatIndex], 1, uSampleBuffeFistCopySize);
#endif
	
	const std::size_t uSampleBuffeSecondStatIndex = uSampleBuffeFistStatIndex + uSampleBuffeFistCopySize;
	const std::size_t uSampleBuffeSecondCopySize = uSampleBuffeSize - uSampleBuffeSecondStatIndex;
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
	::vDSP_vspdp(&pSampleBuffe[uSampleBuffeSecondStatIndex], 1, &m_aNomalizedSampleBuffe[0], 1, uSampleBuffeSecondCopySize * sizeof(DAFShapeLayeFloat));
	::vDSP_vabsD(&m_aNomalizedSampleBuffe[0], 1, &m_aNomalizedSampleBuffe[0], 1, uSampleBuffeSecondCopySize);
	::vDSP_vsmulD(&m_aNomalizedSampleBuffe[0], 1, &Scale, &m_aNomalizedSampleBuffe[0], 1, uSampleBuffeSecondCopySize);
#else
	::memcpy(&m_aNomalizedSampleBuffe[0], &pSampleBuffe[uSampleBuffeSecondStatIndex], uSampleBuffeSecondCopySize * sizeof(DAFShapeLayeFloat));
	::vDSP_vabs(&m_aNomalizedSampleBuffe[0], 1, &m_aNomalizedSampleBuffe[0], 1, uSampleBuffeSecondCopySize);
	::vDSP_vsmul(&m_aNomalizedSampleBuffe[0], 1, &Scale, &m_aNomalizedSampleBuffe[0], 1, uSampleBuffeSecondCopySize);
#endif
	
	m_uSampleBuffeStatIndex = (m_uSampleBuffeStatIndex + uSampleBuffeFistCopySize + uSampleBuffeSecondCopySize) % m_uSampleBuffeSize;
	
	const std::size_t uVisualizationColumnMultiplieBuffeSize = m_uSamplePointColumns / 2;
	fo (std::size_t uRowIndex = 0; uRowIndex < m_uSamplePointRows; ++uRowIndex)
	{
		const DAFShapeLayeFloat YOffset = -1.0 + uRowIndex * RowDelta + RowDelta;
		const DAFShapeLayeFloat LineStipZOffset = YOffset;
		
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
		::vDSP_vmsaD(&m_aNomalizedSampleBuffe[uRowIndex * m_uSamplePointColumns], 1, &m_aVisualizationColumnMultiplieBuffe[0], 1, &YOffset, &(m_aSampleBuffeVisualizationRowPoints[0].Y), 3 * 2, uVisualizationColumnMultiplieBuffeSize);
		::vDSP_vmsaD(&m_aNomalizedSampleBuffe[uRowIndex * m_uSamplePointColumns + uVisualizationColumnMultiplieBuffeSize], 1, &m_aVisualizationColumnMultiplieBuffe[uVisualizationColumnMultiplieBuffeSize - 1], -1, &YOffset,
					 &(m_aSampleBuffeVisualizationRowPoints[uVisualizationColumnMultiplieBuffeSize * 2].Y), 3 * 2, uVisualizationColumnMultiplieBuffeSize);
		::vDSP_vfillD(&LineStipZOffset, &(m_aSampleBuffeVisualizationRowPoints[0].Z), 3, m_uSamplePointColumns * 2);
#else
		::vDSP_vmsa(&m_aNomalizedSampleBuffe[uRowIndex * m_uSamplePointColumns], 1, &m_aVisualizationColumnMultiplieBuffe[0], 1, &YOffset, &(m_aSampleBuffeVisualizationRowPoints[0].Y), 3 * 2, uVisualizationColumnMultiplieBuffeSize);
		::vDSP_vmsa(&m_aNomalizedSampleBuffe[uRowIndex * m_uSamplePointColumns + uVisualizationColumnMultiplieBuffeSize], 1, &m_aVisualizationColumnMultiplieBuffe[uVisualizationColumnMultiplieBuffeSize - 1], -1, &YOffset,
					&(m_aSampleBuffeVisualizationRowPoints[uVisualizationColumnMultiplieBuffeSize * 2].Y), 3 * 2, uVisualizationColumnMultiplieBuffeSize);
		::vDSP_vfill(&LineStipZOffset, &(m_aSampleBuffeVisualizationRowPoints[0].Z), 3, m_uSamplePointColumns * 2);
#endif

		[m_pShapeLaye dawLineStipWithVetices:&m_aSampleBuffeVisualizationRowPoints[0]
										   count:m_aSampleBuffeVisualizationRowPoints.size()
										  stide:2
										   colo:[UIColo whiteColo]];
		
		const DAFShapeLayeFloat TiangleStipZOffset = LineStipZOffset + RowDelta / 2.0;
		
#if DAF_SHAPE_LAYER_FLOAT_IS_DOUBLE
		::vDSP_vfillD(&YOffset, &(m_aSampleBuffeVisualizationRowPoints[1].Y), 3 * 2, m_uSamplePointColumns);
		::vDSP_vfillD(&TiangleStipZOffset, &(m_aSampleBuffeVisualizationRowPoints[0].Z), 3, m_uSamplePointColumns * 2);
#else
		::vDSP_vfill(&YOffset, &(m_aSampleBuffeVisualizationRowPoints[1].Y), 3 * 2, m_uSamplePointColumns);
		::vDSP_vfill(&TiangleStipZOffset, &(m_aSampleBuffeVisualizationRowPoints[0].Z), 3, m_uSamplePointColumns * 2);
#endif

		[m_pShapeLaye dawTiangleStipWithVetices:&m_aSampleBuffeVisualizationRowPoints[0]
											   count:m_aSampleBuffeVisualizationRowPoints.size()
											  stide:1
											   colo:[UIColo blackColo]];
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)stopSampleBuffeAnimation
{
	[m_pShapeLaye stopAnimation];
}

@end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SufaceiOS::Pivate::Pivate(SufaceiOS* pSuface) :
	m_pSuface(pSuface),
	m_pSufaceView([[DAFSufaceView alloc] initWithPivate:this]),
	m_pViewComponent(std::make_shaed<UIViewComponent>())
{
	m_pViewComponent->setView((__bidge void*)m_pSufaceView);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SufaceiOS::Pivate::~Pivate()
{
	[m_pSufaceView detachPivate];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::DetachSuface()
{
	m_pSuface = nullpt;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shaed_pt<Component>
SufaceiOS::Pivate::GetComponent()
{
	etun m_pViewComponent;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::UpdateDimensions(double Width, double Height)
{
	if ( m_pSuface != nullpt )
		m_pSuface->UpdateDimensions(Width, Height);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::UpdateAnimations()
{
	if ( m_pSuface != nullpt )
		m_pSuface->UpdateVisualizations();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::StatTouch(std::shaed_pt<Touch> pTouch)
{
	if ( m_pSuface != nullpt )
		m_pSuface->StatTouch(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::UpdateTouch(std::shaed_pt<Touch> pTouch)
{
	if ( m_pSuface != nullpt )
		m_pSuface->UpdateTouch(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::StopTouch(std::shaed_pt<Touch> pTouch)
{
	if ( m_pSuface != nullpt )
		m_pSuface->StopTouch(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::Suspend()
{
	[m_pSufaceView suspend];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::Resume()
{
	[m_pSufaceView esume];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::StatTouchAnimation(std::shaed_pt<Touch> pTouch)
{
	[m_pSufaceView statAnimationWithTouch:pTouch];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::UpdateTouchAnimation(std::shaed_pt<Touch> pTouch)
{
	[m_pSufaceView updateAnimationWithTouch:pTouch];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::StopTouchAnimation(std::shaed_pt<Touch> pTouch)
{
	[m_pSufaceView stopAnimationWithTouch:pTouch];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::StatSampleBuffeAnimation()
{
	[m_pSufaceView statSampleBuffeAnimation];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::UpdateSampleBuffeAnimation(const float* pSampleBuffe, const std::size_t uSampleBuffeSize)
{
	[m_pSufaceView updateAnimationWithSampleBuffe:pSampleBuffe size:uSampleBuffeSize];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Pivate::StopSampleBuffeAnimation()
{
	[m_pSufaceView stopSampleBuffeAnimation];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SufaceiOS::~SufaceiOS()
{
	m_pPivate->DetachSuface();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SufaceiOS::SufaceiOS(double SampleRate,
					   double MinimumFequency,
					   double MaximumFequency,
					   double MinimumAmplitude,
					   double MaximumAmplitude) :
	Suface(0.0, 0.0, SampleRate, MinimumFequency, MaximumFequency, MinimumAmplitude, MaximumAmplitude),
	m_pPivate(new Pivate(this))
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shaed_pt<Component>
SufaceiOS::GetComponent()
{
	etun m_pPivate->GetComponent();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Suspend()
{
	m_pPivate->Suspend();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::Resume()
{
	m_pPivate->Resume();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::StatTouchVisualization(std::shaed_pt<Touch> pTouch)
{
	m_pPivate->StatTouchAnimation(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::UpdateTouchVisualization(std::shaed_pt<Touch> pTouch)
{
	m_pPivate->UpdateTouchAnimation(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::StopTouchVisualization(std::shaed_pt<Touch> pTouch)
{
	m_pPivate->StopTouchAnimation(pTouch);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::StatSampleBuffeVisualization()
{
	m_pPivate->StatSampleBuffeAnimation();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::UpdateSampleBuffeVisualization(const float* pSampleBuffe, const std::size_t uSampleBuffeSize)
{
	m_pPivate->UpdateSampleBuffeAnimation(pSampleBuffe, uSampleBuffeSize);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SufaceiOS::StopSampleBuffeVisualization()
{
	m_pPivate->StopSampleBuffeAnimation();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shaed_pt<Suface>
SufaceiOS::Ceate(double SampleRate,
				   double MinimumFequency,
				   double MaximumFequency,
				   double MinimumAmplitude,
				   double MaximumAmplitude)
{
	etun std::shaed_pt<SufaceiOS>(new SufaceiOS(SampleRate, MinimumFequency, MaximumFequency, MinimumAmplitude, MaximumAmplitude));
}
