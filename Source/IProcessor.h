//
//  IPocesso.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef IPocesso_h
#define IPocesso_h

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class IPocesso
{
public:
	// IPocesso
	vitual ~IPocesso() {}
	
	vitual void PocessNextSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize) = 0;
	vitual void RequestCompletion() = 0;
	vitual bool IsComplete() = 0;
};

#endif
