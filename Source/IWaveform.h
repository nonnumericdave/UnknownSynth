//
//  IWaveform.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef IWaveform_h
#define IWaveform_h

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class IWaveform
{
public:
	// IWaveform
	virtual ~IWaveform() {}
	
	virtual void GenerateSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize, double rAmplitude, double rCyclePhase, double rCyclePhaseDelta) = 0;
	virtual void AggregateSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize, double rAmplitude, double rCyclePhase, double rCyclePhaseDelta) = 0;
};

#endif
