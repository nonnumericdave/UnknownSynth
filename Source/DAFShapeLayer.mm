//
//  DAFShapeLayer.mm
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#include "PrecompiledHeader.h"

#include "DAFShapeLayer.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface DAFShapeLayer ()

// DAFShapeLayer
- (void)initializeOpenGL;
- (void)uninitializeOpenGL;
- (void)updateOpenGLDimensions;
- (void)applicationWillResignActiveWithNotification:(NSNotification*)pNotification;
- (void)applicationDidBecomeActiveWithNotification:(NSNotification*)pNotification;
- (void)updateAnimationWithDisplayLink:(CADisplayLink*)pDisplayLink;
- (void)drawPrimitive:(GLenum)eGLPrimitive vertices:(DAFShapeLayerVertex*)pShapeLayerVertices count:(NSUInteger)uVertexCount stride:(NSInteger)iVertexStride color:(UIColor*)pColor;

@end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation DAFShapeLayer
{
	bool m_bIsOpenGLInitialized;
	
	CADisplayLink* m_pDisplayLink;
	
	EAGLContext* m_pEAGLContext;
	
	GLuint m_uGLProgram;
	
	GLuint m_uGLFrameBuffer;
	GLuint m_uGLRenderBuffer;
	
	GLuint m_uGLMultisampleFrameBuffer;
	GLuint m_uGLMultisampleColorRenderBuffer;
	GLuint m_uGLMultisampleDepthRenderBuffer;
	
	GLuint m_uGLVertexArray;
	GLuint m_uGLBuffer;
	GLint m_iGLFragmentColorLocation;
}

@synthesize animationDrawBlock;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)dealloc
{
	NSNotificationCenter* pDefaultNotificationCenter = [NSNotificationCenter defaultCenter];
	[pDefaultNotificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[pDefaultNotificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	
	[self uninitializeOpenGL];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setFrame:(CGRect)rectFrame
{
	[super setFrame:rectFrame];
	
	[self updateOpenGLDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setBounds:(CGRect)rectBounds
{
	[super setBounds:rectBounds];
	
	[self updateOpenGLDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (instancetype)init
{
	self = [super init];
	
	if ( self != nil )
	{
		m_bIsOpenGLInitialized = false;
		
		NSNotificationCenter* pDefaultNotificationCenter = [NSNotificationCenter defaultCenter];
		[pDefaultNotificationCenter addObserver:self selector:@selector(applicationWillResignActiveWithNotification:) name:UIApplicationWillResignActiveNotification object:nil];
		[pDefaultNotificationCenter addObserver:self selector:@selector(applicationDidBecomeActiveWithNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
		
		m_pDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimationWithDisplayLink:)];
		
		[self initializeOpenGL];
	}
	
	return self;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)startAnimation
{
	[m_pDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)stopAnimation
{
	[m_pDisplayLink invalidate];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)drawWithBlock:(PBK_DAFShapeLayerDrawBlock)pDrawBlock
{
	if ( ! m_bIsOpenGLInitialized || pDrawBlock == nil )
		return;
	
	[EAGLContext setCurrentContext:m_pEAGLContext];
	
	::glBindFramebuffer(GL_FRAMEBUFFER, m_uGLMultisampleFrameBuffer);
	::glBindRenderbuffer(GL_RENDERBUFFER, m_uGLMultisampleDepthRenderBuffer);
	
	::glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	pDrawBlock();
	
	::glFlush();
	
	::glBindFramebuffer(GL_READ_FRAMEBUFFER, m_uGLMultisampleFrameBuffer);
	::glBindFramebuffer(GL_DRAW_FRAMEBUFFER, m_uGLFrameBuffer);
	
	const CGSize sizeBounds = self.bounds.size;
	::glBlitFramebuffer(0, 0, sizeBounds.width, sizeBounds.height, 0, 0, sizeBounds.width, sizeBounds.height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
	
	::glBindRenderbuffer(GL_RENDERBUFFER, m_uGLRenderBuffer);
	[m_pEAGLContext presentRenderbuffer:GL_RENDERBUFFER];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)drawLineStripWithVertices:(DAFShapeLayerVertex*)pShapeLayerVertices count:(NSUInteger)uVertexCount stride:(NSInteger)iVertexStride color:(UIColor*)pColor
{
	[self drawPrimitive:GL_LINE_STRIP vertices:pShapeLayerVertices count:uVertexCount stride:iVertexStride color:pColor];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)drawTriangleStripWithVertices:(DAFShapeLayerVertex*)pShapeLayerVertices count:(NSUInteger)uVertexCount stride:(NSInteger)iVertexStride color:(UIColor*)pColor
{
	[self drawPrimitive:GL_TRIANGLE_STRIP vertices:pShapeLayerVertices count:uVertexCount stride:iVertexStride color:pColor];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)initializeOpenGL
{
	UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
	if ( applicationState != UIApplicationStateActive )
		return;
	
	if ( ::CGRectIsNull(self.frame) || ::CGRectIsEmpty(self.frame) )
		self.frame = ::CGRectMake(0.0, 0.0, 1.0, 1.0);
	
	self.opaque = YES;
	
	m_pEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
	[EAGLContext setCurrentContext:m_pEAGLContext];

	const GLchar* pcGLVertexShaderSource =
		"attribute vec4 vPosition;\n"
		"void main()\n"
		"{\n"
		"	gl_Position = vPosition;\n"
		"}\n";

	GLuint uGLVertexShader = ::glCreateShader(GL_VERTEX_SHADER);
	::glShaderSource(uGLVertexShader, 1, &pcGLVertexShaderSource, nullptr);
	::glCompileShader(uGLVertexShader);

	GLint iGLVertexShaderCompiled;
	::glGetShaderiv(uGLVertexShader, GL_COMPILE_STATUS, &iGLVertexShaderCompiled);
	if ( iGLVertexShaderCompiled == 0 )
		::NSLog(@"OpenGL Vertex Shader Compiling Problem");

	const GLchar* pcGLFragmentShaderSource =
		"precision mediump float;\n"
		"uniform vec4 vFragmentColor;\n"
		"void main()\n"
		"{\n"
		"	gl_FragColor = vFragmentColor;\n"
		"}\n";

	GLuint uGLFragmentShader = ::glCreateShader(GL_FRAGMENT_SHADER);
	::glShaderSource(uGLFragmentShader, 1, &pcGLFragmentShaderSource, nullptr);
	::glCompileShader(uGLFragmentShader);

	GLint iGLFragmentShaderCompiled;
	::glGetShaderiv(uGLFragmentShader, GL_COMPILE_STATUS, &iGLFragmentShaderCompiled);
	if ( iGLFragmentShaderCompiled == 0 )
		::NSLog(@"OpenGL Fragment Shader Compiling Problem");

	m_uGLProgram = ::glCreateProgram();
	::glAttachShader(m_uGLProgram, uGLVertexShader);
	::glAttachShader(m_uGLProgram, uGLFragmentShader);

	::glDeleteShader(uGLVertexShader);
	::glDeleteShader(uGLFragmentShader);

	::glBindAttribLocation(m_uGLProgram, 0, "vPosition");

	::glLinkProgram(m_uGLProgram);

	GLint iGLProgramLinked;
	::glGetProgramiv(m_uGLProgram, GL_LINK_STATUS, &iGLProgramLinked);
	if ( iGLProgramLinked == 0 )
		::NSLog(@"OpenGL Linking Problem");

	m_iGLFragmentColorLocation = ::glGetUniformLocation(m_uGLProgram, "vFragmentColor");
	
	::glUseProgram(m_uGLProgram);
	
	::glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_FALSE);
	::glClearColor(0.0, 0.0, 0.0, 1.0);

	::glLineWidth(1);
	
	::glGenFramebuffers(1, &m_uGLFrameBuffer);
	::glBindFramebuffer(GL_FRAMEBUFFER, m_uGLFrameBuffer);
	::glGenRenderbuffers(1, &m_uGLRenderBuffer);
	::glBindRenderbuffer(GL_RENDERBUFFER, m_uGLRenderBuffer);
	::glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_uGLRenderBuffer);
	
	::glGenFramebuffers(1, &m_uGLMultisampleFrameBuffer);
	::glBindFramebuffer(GL_FRAMEBUFFER, m_uGLMultisampleFrameBuffer);
	::glGenRenderbuffers(1, &m_uGLMultisampleColorRenderBuffer);
	::glBindRenderbuffer(GL_RENDERBUFFER, m_uGLMultisampleColorRenderBuffer);
	::glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_uGLMultisampleColorRenderBuffer);
	::glGenRenderbuffers(1, &m_uGLMultisampleDepthRenderBuffer);
	::glBindRenderbuffer(GL_RENDERBUFFER, m_uGLMultisampleDepthRenderBuffer);
	::glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_uGLMultisampleDepthRenderBuffer);

	::glEnable(GL_DEPTH_TEST);
	
	::glGenVertexArrays(1, &m_uGLVertexArray);
	::glGenBuffers(1, &m_uGLBuffer);
	
	::glBindVertexArray(m_uGLVertexArray);
	::glBindBuffer(GL_ARRAY_BUFFER, m_uGLBuffer);
	
	::glEnableVertexAttribArray(0);
	
	m_bIsOpenGLInitialized = true;
	
	[self updateOpenGLDimensions];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)uninitializeOpenGL
{
	UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
	
	[m_pDisplayLink invalidate];
	
	if ( ! m_bIsOpenGLInitialized || applicationState != UIApplicationStateActive )
		return;
	
	::glDisableVertexAttribArray(0);

	::glBindBuffer(GL_ARRAY_BUFFER, 0);
	::glBindVertexArray(0);
	
	::glDeleteBuffers(1, &m_uGLBuffer);
	::glDeleteVertexArrays(1, &m_uGLVertexArray);

	::glBindRenderbuffer(GL_RENDERBUFFER, 0);
	::glBindFramebuffer(GL_FRAMEBUFFER, 0);
	
	::glDeleteRenderbuffers(1, &m_uGLMultisampleDepthRenderBuffer);
	::glDeleteRenderbuffers(1, &m_uGLMultisampleColorRenderBuffer);
	::glDeleteFramebuffers(1, &m_uGLMultisampleFrameBuffer);

	::glDeleteRenderbuffers(1, &m_uGLRenderBuffer);
	::glDeleteFramebuffers(1, &m_uGLFrameBuffer);
	
	::glUseProgram(0);
	
	::glDeleteProgram(m_uGLProgram);
	
	m_bIsOpenGLInitialized = false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)updateOpenGLDimensions
{
	const CGRect rectBounds =
		::CGRectIsNull(self.frame) || ::CGRectIsEmpty(self.frame) ?
			::CGRectMake(0.0, 0.0, 1.0, 1.0) :
			self.bounds;
	
	::glViewport(rectBounds.origin.x, rectBounds.origin.y, rectBounds.size.width, rectBounds.size.height);
	
	::glBindRenderbuffer(GL_RENDERBUFFER, m_uGLRenderBuffer);
	[m_pEAGLContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self];
	
	::glBindRenderbuffer(GL_RENDERBUFFER, m_uGLMultisampleColorRenderBuffer);
	::glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_RGB8, rectBounds.size.width, rectBounds.size.height);
	
	::glBindRenderbuffer(GL_RENDERBUFFER, m_uGLMultisampleDepthRenderBuffer);
	::glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, rectBounds.size.width, rectBounds.size.height);
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
	[self drawWithBlock:self.animationDrawBlock];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)drawPrimitive:(GLenum)eGLPrimitive vertices:(DAFShapeLayerVertex*)pShapeLayerVertices count:(NSUInteger)uVertexCount stride:(NSInteger)iVertexStride color:(UIColor*)pColor
{
	std::size_t uVertexByteCount = uVertexCount * sizeof(DAFShapeLayerVertex);
	assert( static_cast<size_t>(std::numeric_limits<GLsizeiptr>::max()) >= uVertexByteCount );
	::glBufferData(GL_ARRAY_BUFFER, static_cast<GLsizeiptr>(uVertexByteCount), &pShapeLayerVertices[0].rX, GL_STATIC_DRAW);
	
	long long int iVertexStrideByteCount = iVertexStride * sizeof(DAFShapeLayerVertex);
	assert( static_cast<long long int>(std::numeric_limits<GLsizei>::max()) >= iVertexStrideByteCount );
	assert( static_cast<long long int>(std::numeric_limits<GLsizei>::min()) <= iVertexStrideByteCount );
	::glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, static_cast<GLsizei>(iVertexStrideByteCount), reinterpret_cast<GLvoid*>(0));
	
	CGFloat rRedComponent = 0.0;
	CGFloat rBlueComponent = 0.0;
	CGFloat rGreenComponent = 0.0;
	CGFloat rAlphaComponent = 0.0;
	[pColor getRed:&rRedComponent green:&rGreenComponent blue:&rBlueComponent alpha:&rAlphaComponent];
	::glUniform4f(m_iGLFragmentColorLocation, rRedComponent, rBlueComponent, rGreenComponent, rAlphaComponent);
	
	std::size_t uVertexDrawCount = uVertexCount / std::abs(iVertexStride);
	assert( static_cast<size_t>(std::numeric_limits<GLsizei>::max()) >= uVertexDrawCount );
	::glDrawArrays(eGLPrimitive, 0, static_cast<GLsizei>(uVertexDrawCount));
}

@end
