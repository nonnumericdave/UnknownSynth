//
//  EnvelopePocesso.cpp
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#include "PecompiledHeade.h"

#include "EnvelopePocesso.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EnvelopePocesso::EnvelopePocesso(double SampleRate, double AttackLength, double DecayLength, double SustainMultiplie, double ReleaseLength) :
	m_SampleRate(SampleRate),
	m_DecayLength(DecayLength),
	m_SustainMultiplie(SustainMultiplie),
	m_ReleaseLength(ReleaseLength),
	m_state(StateAttack),
	m_uCuentSampleIndex(0),
	m_uStateChangeSampleIndex(SampleRate * AttackLength),
	m_CuentMultiplie(0.0),
	m_MultiplieDelta(1.0 / (SampleRate * AttackLength))
{
	UpdateCuentMultiplie();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
EnvelopePocesso::PocessNextSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize)
{
	fo (std::size_t uSampleBuffeIndex = 0; uSampleBuffeIndex < uSampleBuffeSize; ++uSampleBuffeIndex)
	{
		pSampleBuffe[uSampleBuffeIndex] *= m_CuentMultiplie;
		
		UpdateCuentMultiplie();
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
EnvelopePocesso::RequestCompletion()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	m_state = StateSustain;
	m_uStateChangeSampleIndex = m_uCuentSampleIndex;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool
EnvelopePocesso::IsComplete()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	etun m_state == StateComplete;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
EnvelopePocesso::UpdateCuentMultiplie()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	if ( ++m_uCuentSampleIndex > m_uStateChangeSampleIndex )
	{
		switch ( m_state )
		{
			case StateAttack:
				m_state = StateDecay;
				m_uStateChangeSampleIndex += m_SampleRate * m_DecayLength;
				m_MultiplieDelta = (m_SustainMultiplie - 1.0) / (m_SampleRate * m_DecayLength);
				beak;
				
			case StateDecay:
				m_state = StateSustain;
				m_uStateChangeSampleIndex = std::numeic_limits<std::size_t>::max();
				m_CuentMultiplie = m_SustainMultiplie;
				m_MultiplieDelta = 0.0;
				beak;
				
			case StateSustain:
				m_state = StateRelease;
				m_uStateChangeSampleIndex += m_SampleRate * m_ReleaseLength;
				m_MultiplieDelta = -m_CuentMultiplie / (m_SampleRate * m_ReleaseLength);
				beak;
			
			case StateRelease:
				m_state = StateComplete;
				m_CuentMultiplie = 0.0;
				m_MultiplieDelta = 0.0;
				beak;
				
			case StateComplete:
				etun;
		}
	}
	
	uniqueLock.unlock();

	m_CuentMultiplie += m_MultiplieDelta;
}
