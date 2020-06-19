//
//  EnvelopeProcessor.cpp
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#include "PrecompiledHeader.h"

#include "EnvelopeProcessor.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EnvelopeProcessor::EnvelopeProcessor(double rSampleRate, double rAttackLength, double rDecayLength, double rSustainMultiplier, double rReleaseLength) :
	m_rSampleRate(rSampleRate),
	m_rDecayLength(rDecayLength),
	m_rSustainMultiplier(rSustainMultiplier),
	m_rReleaseLength(rReleaseLength),
	m_state(StateAttack),
	m_uCurrentSampleIndex(0),
	m_uStateChangeSampleIndex(rSampleRate * rAttackLength),
	m_rCurrentMultiplier(0.0),
	m_rMultiplierDelta(1.0 / (rSampleRate * rAttackLength))
{
	UpdateCurrentMultiplier();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
EnvelopeProcessor::ProcessNextSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize)
{
	for (std::size_t uSampleBufferIndex = 0; uSampleBufferIndex < uSampleBufferSize; ++uSampleBufferIndex)
	{
		prSampleBuffer[uSampleBufferIndex] *= m_rCurrentMultiplier;
		
		UpdateCurrentMultiplier();
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
EnvelopeProcessor::RequestCompletion()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	m_state = StateSustain;
	m_uStateChangeSampleIndex = m_uCurrentSampleIndex;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool
EnvelopeProcessor::IsComplete()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	return m_state == StateComplete;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
EnvelopeProcessor::UpdateCurrentMultiplier()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	if ( ++m_uCurrentSampleIndex > m_uStateChangeSampleIndex )
	{
		switch ( m_state )
		{
			case StateAttack:
				m_state = StateDecay;
				m_uStateChangeSampleIndex += m_rSampleRate * m_rDecayLength;
				m_rMultiplierDelta = (m_rSustainMultiplier - 1.0) / (m_rSampleRate * m_rDecayLength);
				break;
				
			case StateDecay:
				m_state = StateSustain;
				m_uStateChangeSampleIndex = std::numeric_limits<std::size_t>::max();
				m_rCurrentMultiplier = m_rSustainMultiplier;
				m_rMultiplierDelta = 0.0;
				break;
				
			case StateSustain:
				m_state = StateRelease;
				m_uStateChangeSampleIndex += m_rSampleRate * m_rReleaseLength;
				m_rMultiplierDelta = -m_rCurrentMultiplier / (m_rSampleRate * m_rReleaseLength);
				break;
			
			case StateRelease:
				m_state = StateComplete;
				m_rCurrentMultiplier = 0.0;
				m_rMultiplierDelta = 0.0;
				break;
				
			case StateComplete:
				return;
		}
	}
	
	uniqueLock.unlock();

	m_rCurrentMultiplier += m_rMultiplierDelta;
}
