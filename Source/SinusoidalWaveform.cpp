//
//  SinusoidalWaveform.cpp
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#include "PrecompiledHeader.h"

#include "SinusoidalWaveform.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SinusoidalWaveform::GenerateSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize, double rAmplitude, double rCyclePhase, double rCyclePhaseDelta)
{
	for (std::size_t uSampleBufferIndex = 0; uSampleBufferIndex < uSampleBufferSize; ++uSampleBufferIndex)
	{
		prSampleBuffer[uSampleBufferIndex] = std::sin(rCyclePhase * 2.0 * M_PI) * rAmplitude;
		
		rCyclePhase += rCyclePhaseDelta;
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
SinusoidalWaveform::AggregateSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize, double rAmplitude, double rCyclePhase, double rCyclePhaseDelta)
{
	for (std::size_t uSampleBufferIndex = 0; uSampleBufferIndex < uSampleBufferSize; ++uSampleBufferIndex)
	{
		prSampleBuffer[uSampleBufferIndex] += std::sin(rCyclePhase * 2.0 * M_PI) * rAmplitude;
		
		rCyclePhase += rCyclePhaseDelta;
	}
}
