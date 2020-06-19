//
//  Signal.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef Signal_h
#define Signal_h

#include "IProcessor.h"
#include "IWaveform.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Signal
{
public:
	// Signal
	Signal(double rSampleRate, double rInitialFrequency, double rInitialAmplitude, std::shared_ptr<IWaveform> pWaveform, std::shared_ptr<IProcessor> pProcessor);
	
	void SetFrequency(double rUpdatedFrequency);
	void SetAmplitude(double rUpdatedAmplitude);
	
	void GenerateNextSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize);
	void AggregateNextSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize);
	
	std::shared_ptr<IProcessor> GetProcessor();
	
private:
	// Signal
	void UpdateCyclePhase(std::size_t uSampleCount);
	void UpdateCyclePhaseDelta();
	
	std::mutex m_mutex;
	
	double m_rSampleRate;
	double m_rFrequency;
	double m_rAmplitude;

	double m_rCyclePhase;
	double m_rCyclePhaseDelta;
	
	std::shared_ptr<IWaveform> m_pWaveform;
	std::shared_ptr<IProcessor> m_pProcessor;
};

#endif
