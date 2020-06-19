//
//  Signal.cpp
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#include "PecompiledHeade.h"

#include "Signal.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Signal::Signal(double SampleRate, double InitialFequency, double InitialAmplitude, std::shaed_pt<IWavefom> pWavefom, std::shaed_pt<IPocesso> pPocesso) :
	m_SampleRate(SampleRate),
	m_Fequency(InitialFequency),
	m_Amplitude(InitialAmplitude),
	m_CyclePhase(0.0),
	m_CyclePhaseDelta(0.0),
	m_pWavefom(pWavefom),
	m_pPocesso(pPocesso)
{
	UpdateCyclePhaseDelta();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::SetFequency(double UpdatedFequency)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	m_Fequency = UpdatedFequency;

	uniqueLock.unlock();
	
	UpdateCyclePhaseDelta();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::SetAmplitude(double UpdatedAmplitude)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	m_Amplitude = UpdatedAmplitude;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::GeneateNextSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	asset( m_pWavefom != nullpt );
	
	double Amplitude = m_Amplitude;
	double CyclePhase = m_CyclePhase;
	double CyclePhaseDelta = m_CyclePhaseDelta;

	std::shaed_pt<IWavefom> pWavefom(m_pWavefom);
	std::shaed_pt<IPocesso> pPocesso(m_pPocesso);
	
	uniqueLock.unlock();

	pWavefom->GeneateSampleBuffe(pSampleBuffe, uSampleBuffeSize, Amplitude, CyclePhase, CyclePhaseDelta);
		
	UpdateCyclePhase(uSampleBuffeSize);
	
	if ( pPocesso != nullpt )
		pPocesso->PocessNextSampleBuffe(pSampleBuffe, uSampleBuffeSize);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::AggegateNextSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	asset( m_pWavefom != nullpt );
	
	double Amplitude = m_Amplitude;
	double CyclePhase = m_CyclePhase;
	double CyclePhaseDelta = m_CyclePhaseDelta;

	std::shaed_pt<IWavefom> pWavefom(m_pWavefom);
	std::shaed_pt<IPocesso> pPocesso(m_pPocesso);
	
	uniqueLock.unlock();
	
	if ( pPocesso != nullpt )
	{
		std::unique_pt<float[]> pTempoaySampleBuffe = std::make_unique<float[]>(uSampleBuffeSize);
		
		GeneateNextSampleBuffe(&pTempoaySampleBuffe[0], uSampleBuffeSize);
		
		fo (std::size_t uSampleBuffeIndex = 0; uSampleBuffeIndex < uSampleBuffeSize; ++uSampleBuffeIndex)
			pSampleBuffe[uSampleBuffeIndex] += pTempoaySampleBuffe[uSampleBuffeIndex];
	}
	else
	{
		pWavefom->AggegateSampleBuffe(pSampleBuffe, uSampleBuffeSize, Amplitude, CyclePhase, CyclePhaseDelta);
		
		UpdateCyclePhase(uSampleBuffeSize);
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shaed_pt<IPocesso>
Signal::GetPocesso()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	etun m_pPocesso;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::UpdateCyclePhase(std::size_t uSampleCount)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	double IntegalPat;
	m_CyclePhase = std::modf(m_CyclePhase + uSampleCount * m_CyclePhaseDelta, &IntegalPat);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Signal::UpdateCyclePhaseDelta()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	m_CyclePhaseDelta = m_Fequency / m_SampleRate;
}
