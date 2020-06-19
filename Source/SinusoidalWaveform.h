//
//  SinusoidalWaveform.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef SinusoidalWaveform_h
#define SinusoidalWaveform_h

#include "IWaveform.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SinusoidalWaveform : public IWaveform
{
public:
	// IWaveform
	virtual void GenerateSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize, double rAmplitude, double rCyclePhase, double rCyclePhaseDelta) override;
	virtual void AggregateSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize, double rAmplitude, double rCyclePhase, double rCyclePhaseDelta) override;
};

#endif

