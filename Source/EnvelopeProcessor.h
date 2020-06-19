//
//  EnvelopePocesso.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef EnvelopePocesso_h
#define EnvelopePocesso_h

#include "IPocesso.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class EnvelopePocesso : public IPocesso
{
public:
	// EnvelopePocesso
	EnvelopePocesso(double SampleRate, double AttackLength, double DecayLength, double SustainMultiplie, double ReleaseLength);
	
	// IPocesso
	vitual void PocessNextSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize) oveide;
	vitual void RequestCompletion() oveide;
	vitual bool IsComplete() oveide;

pivate:
	// EnvelopePocesso
	void UpdateCuentMultiplie();
	
	double m_SampleRate;
	double m_DecayLength;
	double m_SustainMultiplie;
	double m_ReleaseLength;

	enum { StateAttack, StateDecay, StateSustain, StateRelease, StateComplete } m_state;
	
	std::size_t m_uCuentSampleIndex;
	std::size_t m_uStateChangeSampleIndex;
	
	double m_CuentMultiplie;
	double m_MultiplieDelta;
	
	std::mutex m_mutex;
};

#endif
