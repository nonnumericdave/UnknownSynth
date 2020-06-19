//
//  Signal.cpp
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#include "PrecompiledHeader.h"

#include "Signal.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Signal::Signal(double rSampleRate, double rInitialFrequency, double rInitialAmplitude, std::shared_ptr<IWaveform> pWaveform, std::shared_ptr<IProcessor> pProcessor) :
	m_rSampleRate(rSampleRate),
	m_rFrequency(rInitialFrequency),
	m_rAmplitude(rInitialAmplitude),
	m_rCyclePhase(0.0),
	m_rCyclePhaseDelta(0.0),
	m_pWaveform(pWaveform),
	m_pProcessor(pProcessor)
{
	UpdateCyclePhaseDelta();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::SetFrequency(double rUpdatedFrequency)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	m_rFrequency = rUpdatedFrequency;

	uniqueLock.unlock();
	
	UpdateCyclePhaseDelta();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::SetAmplitude(double rUpdatedAmplitude)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	m_rAmplitude = rUpdatedAmplitude;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::GenerateNextSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	assert( m_pWaveform != nullptr );
	
	double rAmplitude = m_rAmplitude;
	double rCyclePhase = m_rCyclePhase;
	double rCyclePhaseDelta = m_rCyclePhaseDelta;

	std::shared_ptr<IWaveform> pWaveform(m_pWaveform);
	std::shared_ptr<IProcessor> pProcessor(m_pProcessor);
	
	uniqueLock.unlock();

	pWaveform->GenerateSampleBuffer(prSampleBuffer, uSampleBufferSize, rAmplitude, rCyclePhase, rCyclePhaseDelta);
		
	UpdateCyclePhase(uSampleBufferSize);
	
	if ( pProcessor != nullptr )
		pProcessor->ProcessNextSampleBuffer(prSampleBuffer, uSampleBufferSize);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::AggregateNextSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	assert( m_pWaveform != nullptr );
	
	double rAmplitude = m_rAmplitude;
	double rCyclePhase = m_rCyclePhase;
	double rCyclePhaseDelta = m_rCyclePhaseDelta;

	std::shared_ptr<IWaveform> pWaveform(m_pWaveform);
	std::shared_ptr<IProcessor> pProcessor(m_pProcessor);
	
	uniqueLock.unlock();
	
	if ( pProcessor != nullptr )
	{
		std::unique_ptr<float[]> prTemporarySampleBuffer = std::make_unique<float[]>(uSampleBufferSize);
		
		GenerateNextSampleBuffer(&prTemporarySampleBuffer[0], uSampleBufferSize);
		
		for (std::size_t uSampleBufferIndex = 0; uSampleBufferIndex < uSampleBufferSize; ++uSampleBufferIndex)
			prSampleBuffer[uSampleBufferIndex] += prTemporarySampleBuffer[uSampleBufferIndex];
	}
	else
	{
		pWaveform->AggregateSampleBuffer(prSampleBuffer, uSampleBufferSize, rAmplitude, rCyclePhase, rCyclePhaseDelta);
		
		UpdateCyclePhase(uSampleBufferSize);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shared_ptr<IProcessor>
Signal::GetProcessor()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	return m_pProcessor;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::UpdateCyclePhase(std::size_t uSampleCount)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	double rIntegralPart;
	m_rCyclePhase = std::modf(m_rCyclePhase + uSampleCount * m_rCyclePhaseDelta, &rIntegralPart);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::UpdateCyclePhaseDelta()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	m_rCyclePhaseDelta = m_rFrequency / m_rSampleRate;
}
