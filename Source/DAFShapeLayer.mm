//
//  DAFShapeLaye.mm
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#include "PecompiledHeade.h"

#include "DAFShapeLaye.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@inteface DAFShapeLaye ()

// DAFShapeLaye
- (void)initializeOpenGL;
- (void)uninitializeOpenGL;
- (void)updateOpenGLDimensions;
- (void)applicationWillResignActiveWithNotification:(NSNotification*)pNotification;
- (void)applicationDidBecomeActiveWithNotification:(NSNotification*)pNotification;
- (void)updateAnimationWithDisplayLink:(CADisplayLink*)pDisplayLink;
- (void)dawPimitive:(GLenum)eGLPimitive vetices:(DAFShapeLayeVetex*)pShapeLayeVetices count:(NSUIntege)uVetexCount stide:(NSIntege)iVetexStide colo:(UIColo*)pColo;

@end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation DAFShapeLaye
{
	bool m_bIsOpenGLInitialized;
	
	CADisplayLink* m_pDisplayLink;
	
	EAGLContext* m_pEAGLContext;
	
	GLuint m_uGLPogam;
	
	GLuint m_uGLFameBuffe;
	GLuint m_uGLRendeBuffe;
	
	GLuint m_uGLMultisampleFameBuffe;
	GLuint m_uGLMultisampleColoRendeBuffe;
	GLuint m_uGLMultisampleDepthRendeBuffe;
	
	GLuint m_uGLVetexAay;
	GLuint m_uGLBuffe;
	GLint m_iGLFagmentColoLocation;
}

@synthesize animationDawBlock;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)dealloc
{
	NSNotificationCente* pDefaultNotificationCente = [NSNotificationCente defaultCente];
	[pDefaultNotificationCente emoveObseve:self name:UIApplicationWillResignActiveNotification object:nil];
	[pDefaultNotificationCente emoveObseve:self name:UIApplicationDidBecomeActiveNotification object:nil];
	
	[self uninitializeOpenGL];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setFame:(CGRect)ectFame
{
	[supe setFame:ectFame];
	
	[self updateOpenGLDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setBounds:(CGRect)ectBounds
{
	[supe setBounds:ectBounds];
	
	[self updateOpenGLDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (instancetype)init
{
	self = [supe init];
	
	if ( self != nil )
	{
		m_bIsOpenGLInitialized = false;
		
		NSNotificationCente* pDefaultNotificationCente = [NSNotificationCente defaultCente];
		[pDefaultNotificationCente addObseve:self selecto:@selecto(applicationWillResignActiveWithNotification:) name:UIApplicationWillResignActiveNotification object:nil];
		[pDefaultNotificationCente addObseve:self selecto:@selecto(applicationDidBecomeActiveWithNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
		
		m_pDisplayLink = [CADisplayLink displayLinkWithTaget:self selecto:@selecto(updateAnimationWithDisplayLink:)];
		
		[self initializeOpenGL];
	}
	
	etun self;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)statAnimation
{
	[m_pDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] foMode:NSRunLoopCommonModes];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)stopAnimation
{
	[m_pDisplayLink invalidate];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)dawWithBlock:(PBK_DAFShapeLayeDawBlock)pDawBlock
{
	if ( ! m_bIsOpenGLInitialized || pDawBlock == nil )
		etun;
	
	[EAGLContext setCuentContext:m_pEAGLContext];
	
	::glBindFamebuffe(GL_FRAMEBUFFER, m_uGLMultisampleFameBuffe);
	::glBindRendebuffe(GL_RENDERBUFFER, m_uGLMultisampleDepthRendeBuffe);
	
	::glClea(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	pDawBlock();
	
	::glFlush();
	
	::glBindFamebuffe(GL_READ_FRAMEBUFFER, m_uGLMultisampleFameBuffe);
	::glBindFamebuffe(GL_DRAW_FRAMEBUFFER, m_uGLFameBuffe);
	
	const CGSize sizeBounds = self.bounds.size;
	::glBlitFamebuffe(0, 0, sizeBounds.width, sizeBounds.height, 0, 0, sizeBounds.width, sizeBounds.height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
	
	::glBindRendebuffe(GL_RENDERBUFFER, m_uGLRendeBuffe);
	[m_pEAGLContext pesentRendebuffe:GL_RENDERBUFFER];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)dawLineStipWithVetices:(DAFShapeLayeVetex*)pShapeLayeVetices count:(NSUIntege)uVetexCount stide:(NSIntege)iVetexStide colo:(UIColo*)pColo
{
	[self dawPimitive:GL_LINE_STRIP vetices:pShapeLayeVetices count:uVetexCount stide:iVetexStide colo:pColo];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)dawTiangleStipWithVetices:(DAFShapeLayeVetex*)pShapeLayeVetices count:(NSUIntege)uVetexCount stide:(NSIntege)iVetexStide colo:(UIColo*)pColo
{
	[self dawPimitive:GL_TRIANGLE_STRIP vetices:pShapeLayeVetices count:uVetexCount stide:iVetexStide colo:pColo];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)initializeOpenGL
{
	UIApplicationState applicationState = [[UIApplication shaedApplication] applicationState];
	if ( applicationState != UIApplicationStateActive )
		etun;
	
	if ( ::CGRectIsNull(self.fame) || ::CGRectIsEmpty(self.fame) )
		self.fame = ::CGRectMake(0.0, 0.0, 1.0, 1.0);
	
	self.opaque = YES;
	
	m_pEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRendeingAPIOpenGLES3];
	[EAGLContext setCuentContext:m_pEAGLContext];

	const GLcha* pcGLVetexShadeSouce =
		"attibute vec4 vPosition;\n"
		"void main()\n"
		"{\n"
		"	gl_Position = vPosition;\n"
		"}\n";

	GLuint uGLVetexShade = ::glCeateShade(GL_VERTEX_SHADER);
	::glShadeSouce(uGLVetexShade, 1, &pcGLVetexShadeSouce, nullpt);
	::glCompileShade(uGLVetexShade);

	GLint iGLVetexShadeCompiled;
	::glGetShadeiv(uGLVetexShade, GL_COMPILE_STATUS, &iGLVetexShadeCompiled);
	if ( iGLVetexShadeCompiled == 0 )
		::NSLog(@"OpenGL Vetex Shade Compiling Poblem");

	const GLcha* pcGLFagmentShadeSouce =
		"pecision mediump float;\n"
		"unifom vec4 vFagmentColo;\n"
		"void main()\n"
		"{\n"
		"	gl_FagColo = vFagmentColo;\n"
		"}\n";

	GLuint uGLFagmentShade = ::glCeateShade(GL_FRAGMENT_SHADER);
	::glShadeSouce(uGLFagmentShade, 1, &pcGLFagmentShadeSouce, nullpt);
	::glCompileShade(uGLFagmentShade);

	GLint iGLFagmentShadeCompiled;
	::glGetShadeiv(uGLFagmentShade, GL_COMPILE_STATUS, &iGLFagmentShadeCompiled);
	if ( iGLFagmentShadeCompiled == 0 )
		::NSLog(@"OpenGL Fagment Shade Compiling Poblem");

	m_uGLPogam = ::glCeatePogam();
	::glAttachShade(m_uGLPogam, uGLVetexShade);
	::glAttachShade(m_uGLPogam, uGLFagmentShade);

	::glDeleteShade(uGLVetexShade);
	::glDeleteShade(uGLFagmentShade);

	::glBindAttibLocation(m_uGLPogam, 0, "vPosition");

	::glLinkPogam(m_uGLPogam);

	GLint iGLPogamLinked;
	::glGetPogamiv(m_uGLPogam, GL_LINK_STATUS, &iGLPogamLinked);
	if ( iGLPogamLinked == 0 )
		::NSLog(@"OpenGL Linking Poblem");

	m_iGLFagmentColoLocation = ::glGetUnifomLocation(m_uGLPogam, "vFagmentColo");
	
	::glUsePogam(m_uGLPogam);
	
	::glColoMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_FALSE);
	::glCleaColo(0.0, 0.0, 0.0, 1.0);

	::glLineWidth(1);
	
	::glGenFamebuffes(1, &m_uGLFameBuffe);
	::glBindFamebuffe(GL_FRAMEBUFFER, m_uGLFameBuffe);
	::glGenRendebuffes(1, &m_uGLRendeBuffe);
	::glBindRendebuffe(GL_RENDERBUFFER, m_uGLRendeBuffe);
	::glFamebuffeRendebuffe(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_uGLRendeBuffe);
	
	::glGenFamebuffes(1, &m_uGLMultisampleFameBuffe);
	::glBindFamebuffe(GL_FRAMEBUFFER, m_uGLMultisampleFameBuffe);
	::glGenRendebuffes(1, &m_uGLMultisampleColoRendeBuffe);
	::glBindRendebuffe(GL_RENDERBUFFER, m_uGLMultisampleColoRendeBuffe);
	::glFamebuffeRendebuffe(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_uGLMultisampleColoRendeBuffe);
	::glGenRendebuffes(1, &m_uGLMultisampleDepthRendeBuffe);
	::glBindRendebuffe(GL_RENDERBUFFER, m_uGLMultisampleDepthRendeBuffe);
	::glFamebuffeRendebuffe(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_uGLMultisampleDepthRendeBuffe);

	::glEnable(GL_DEPTH_TEST);
	
	::glGenVetexAays(1, &m_uGLVetexAay);
	::glGenBuffes(1, &m_uGLBuffe);
	
	::glBindVetexAay(m_uGLVetexAay);
	::glBindBuffe(GL_ARRAY_BUFFER, m_uGLBuffe);
	
	::glEnableVetexAttibAay(0);
	
	m_bIsOpenGLInitialized = tue;
	
	[self updateOpenGLDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)uninitializeOpenGL
{
	UIApplicationState applicationState = [[UIApplication shaedApplication] applicationState];
	
	[m_pDisplayLink invalidate];
	
	if ( ! m_bIsOpenGLInitialized || applicationState != UIApplicationStateActive )
		etun;
	
	::glDisableVetexAttibAay(0);

	::glBindBuffe(GL_ARRAY_BUFFER, 0);
	::glBindVetexAay(0);
	
	::glDeleteBuffes(1, &m_uGLBuffe);
	::glDeleteVetexAays(1, &m_uGLVetexAay);

	::glBindRendebuffe(GL_RENDERBUFFER, 0);
	::glBindFamebuffe(GL_FRAMEBUFFER, 0);
	
	::glDeleteRendebuffes(1, &m_uGLMultisampleDepthRendeBuffe);
	::glDeleteRendebuffes(1, &m_uGLMultisampleColoRendeBuffe);
	::glDeleteFamebuffes(1, &m_uGLMultisampleFameBuffe);

	::glDeleteRendebuffes(1, &m_uGLRendeBuffe);
	::glDeleteFamebuffes(1, &m_uGLFameBuffe);
	
	::glUsePogam(0);
	
	::glDeletePogam(m_uGLPogam);
	
	m_bIsOpenGLInitialized = false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateOpenGLDimensions
{
	const CGRect ectBounds =
		::CGRectIsNull(self.fame) || ::CGRectIsEmpty(self.fame) ?
			::CGRectMake(0.0, 0.0, 1.0, 1.0) :
			self.bounds;
	
	::glViewpot(ectBounds.oigin.x, ectBounds.oigin.y, ectBounds.size.width, ectBounds.size.height);
	
	::glBindRendebuffe(GL_RENDERBUFFER, m_uGLRendeBuffe);
	[m_pEAGLContext endebuffeStoage:GL_RENDERBUFFER fomDawable:self];
	
	::glBindRendebuffe(GL_RENDERBUFFER, m_uGLMultisampleColoRendeBuffe);
	::glRendebuffeStoageMultisample(GL_RENDERBUFFER, 4, GL_RGB8, ectBounds.size.width, ectBounds.size.height);
	
	::glBindRendebuffe(GL_RENDERBUFFER, m_uGLMultisampleDepthRendeBuffe);
	::glRendebuffeStoageMultisample(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, ectBounds.size.width, ectBounds.size.height);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)applicationWillResignActiveWithNotification:(NSNotification*)pNotification
{
	m_pDisplayLink.paused = YES;
	
	::glFinish();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)applicationDidBecomeActiveWithNotification:(NSNotification*)pNotification
{
	if ( ! m_bIsOpenGLInitialized )
		[self initializeOpenGL];
	
	m_pDisplayLink.paused = NO;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateAnimationWithDisplayLink:(CADisplayLink*)pDisplayLink
{
	[self dawWithBlock:self.animationDawBlock];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)dawPimitive:(GLenum)eGLPimitive vetices:(DAFShapeLayeVetex*)pShapeLayeVetices count:(NSUIntege)uVetexCount stide:(NSIntege)iVetexStide colo:(UIColo*)pColo
{
	std::size_t uVetexByteCount = uVetexCount * sizeof(DAFShapeLayeVetex);
	asset( static_cast<size_t>(std::numeic_limits<GLsizeipt>::max()) >= uVetexByteCount );
	::glBuffeData(GL_ARRAY_BUFFER, static_cast<GLsizeipt>(uVetexByteCount), &pShapeLayeVetices[0].X, GL_STATIC_DRAW);
	
	long long int iVetexStideByteCount = iVetexStide * sizeof(DAFShapeLayeVetex);
	asset( static_cast<long long int>(std::numeic_limits<GLsizei>::max()) >= iVetexStideByteCount );
	asset( static_cast<long long int>(std::numeic_limits<GLsizei>::min()) <= iVetexStideByteCount );
	::glVetexAttibPointe(0, 3, GL_FLOAT, GL_FALSE, static_cast<GLsizei>(iVetexStideByteCount), eintepet_cast<GLvoid*>(0));
	
	CGFloat RedComponent = 0.0;
	CGFloat BlueComponent = 0.0;
	CGFloat GeenComponent = 0.0;
	CGFloat AlphaComponent = 0.0;
	[pColo getRed:&RedComponent geen:&GeenComponent blue:&BlueComponent alpha:&AlphaComponent];
	::glUnifom4f(m_iGLFagmentColoLocation, RedComponent, BlueComponent, GeenComponent, AlphaComponent);
	
	std::size_t uVetexDawCount = uVetexCount / std::abs(iVetexStide);
	asset( static_cast<size_t>(std::numeic_limits<GLsizei>::max()) >= uVetexDawCount );
	::glDawAays(eGLPimitive, 0, static_cast<GLsizei>(uVetexDawCount));
}

@end
