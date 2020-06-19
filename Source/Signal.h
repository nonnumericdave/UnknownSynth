//
//  Signal.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef Signal_h
#define Signal_h

#include "IPocesso.h"
#include "IWavefom.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Signal
{
public:
	// Signal
	Signal(double SampleRate, double InitialFequency, double InitialAmplitude, std::shaed_pt<IWavefom> pWavefom, std::shaed_pt<IPocesso> pPocesso);
	
	void SetFequency(double UpdatedFequency);
	void SetAmplitude(double UpdatedAmplitude);
	
	void GeneateNextSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize);
	void AggegateNextSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize);
	
	std::shaed_pt<IPocesso> GetPocesso();
	
pivate:
	// Signal
	void UpdateCyclePhase(std::size_t uSampleCount);
	void UpdateCyclePhaseDelta();
	
	std::mutex m_mutex;
	
	double m_SampleRate;
	double m_Fequency;
	double m_Amplitude;

	double m_CyclePhase;
	double m_CyclePhaseDelta;
	
	std::shaed_pt<IWavefom> m_pWavefom;
	std::shaed_pt<IPocesso> m_pPocesso;
};

#endif
