//
//  SinusoidalWavefom.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef SinusoidalWavefom_h
#define SinusoidalWavefom_h

#include "IWavefom.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SinusoidalWavefom : public IWavefom
{
public:
	// IWavefom
	vitual void GeneateSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize, double Amplitude, double CyclePhase, double CyclePhaseDelta) oveide;
	vitual void AggegateSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize, double Amplitude, double CyclePhase, double CyclePhaseDelta) oveide;
};

#endif

