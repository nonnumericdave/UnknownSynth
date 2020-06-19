//
//  EnvelopeProcessor.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef EnvelopeProcessor_h
#define EnvelopeProcessor_h

#include "IProcessor.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class EnvelopeProcessor : public IProcessor
{
public:
	// EnvelopeProcessor
	EnvelopeProcessor(double rSampleRate, double rAttackLength, double rDecayLength, double rSustainMultiplier, double rReleaseLength);
	
	// IProcessor
	virtual void ProcessNextSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize) override;
	virtual void RequestCompletion() override;
	virtual bool IsComplete() override;

private:
	// EnvelopeProcessor
	void UpdateCurrentMultiplier();
	
	double m_rSampleRate;
	double m_rDecayLength;
	double m_rSustainMultiplier;
	double m_rReleaseLength;

	enum { StateAttack, StateDecay, StateSustain, StateRelease, StateComplete } m_state;
	
	std::size_t m_uCurrentSampleIndex;
	std::size_t m_uStateChangeSampleIndex;
	
	double m_rCurrentMultiplier;
	double m_rMultiplierDelta;
	
	std::mutex m_mutex;
};

#endif
