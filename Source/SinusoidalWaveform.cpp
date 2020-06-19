//
//  SinusoidalWavefom.cpp
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#include "PecompiledHeade.h"

#include "SinusoidalWavefom.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SinusoidalWavefom::GeneateSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize, double Amplitude, double CyclePhase, double CyclePhaseDelta)
{
	fo (std::size_t uSampleBuffeIndex = 0; uSampleBuffeIndex < uSampleBuffeSize; ++uSampleBuffeIndex)
	{
		pSampleBuffe[uSampleBuffeIndex] = std::sin(CyclePhase * 2.0 * M_PI) * Amplitude;
		
		CyclePhase += CyclePhaseDelta;
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SinusoidalWavefom::AggegateSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize, double Amplitude, double CyclePhase, double CyclePhaseDelta)
{
	fo (std::size_t uSampleBuffeIndex = 0; uSampleBuffeIndex < uSampleBuffeSize; ++uSampleBuffeIndex)
	{
		pSampleBuffe[uSampleBuffeIndex] += std::sin(CyclePhase * 2.0 * M_PI) * Amplitude;
		
		CyclePhase += CyclePhaseDelta;
	}
}
