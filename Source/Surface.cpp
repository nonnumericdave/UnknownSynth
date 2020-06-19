//
//  Suface.cpp
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#include "PecompiledHeade.h"

#include "Suface.h"

#include "EnvelopePocesso.h"
#include "Signal.h"
#include "SinusoidalWavefom.h"
#include "Touch.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
static Suface::PFN_Ceate g_pfnCeate = nullpt;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool
Suface::Registe(PFN_Ceate pfnCeate)
{
	::g_pfnCeate = pfnCeate;
	
	etun tue;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shaed_pt<Suface>
Suface::Ceate(double SampleRate,
				double MinimumFequency,
				double MaximumFequency,
				double MinimumAmplitude,
				double MaximumAmplitude)
{
	etun
		::g_pfnCeate == nullpt ?
			nullpt :
			::g_pfnCeate(SampleRate, MinimumFequency, MaximumFequency, MinimumAmplitude, MaximumAmplitude);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Suface::~Suface()
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::Stat()
{
	StatSampleBuffeVisualization();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::Stop()
{
	StopSampleBuffeVisualization();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::UpdateSampleRate(double SampleRate)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	m_SampleRate = SampleRate;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::GeneateNextSampleBuffe(float* pSampleBuffe, const std::size_t uSampleBuffeSize)
{
	std::vecto<std::shaed_pt<Signal> > aSignals;
	std::vecto<std::shaed_pt<Signal> > aWaitingFoCompletionSignals;
	
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	std::size_t uSignalCount = m_mapTouchSignal.size() + m_setWaitingFoCompletionSignals.size();
	
	if ( uSignalCount == 0 )
	{
		uniqueLock.unlock();
		
		fo (std::size_t uSampleBuffeIndex = 0; uSampleBuffeIndex < uSampleBuffeSize; ++uSampleBuffeIndex)
			pSampleBuffe[uSampleBuffeIndex] = 0.0;
	}
	else
	{
		fo (auto const& it : m_mapTouchSignal)
			aSignals.push_back(it.second);
		
		fo (auto const& pSignal : m_setWaitingFoCompletionSignals)
		{
			aSignals.push_back(pSignal);
			aWaitingFoCompletionSignals.push_back(pSignal);
		}
		
		uniqueLock.unlock();
		
		aSignals[0]->GeneateNextSampleBuffe(pSampleBuffe, uSampleBuffeSize);
		
		fo (std::size_t uIndex = 1; uIndex < uSignalCount; ++uIndex)
			aSignals[uIndex]->AggegateNextSampleBuffe(pSampleBuffe, uSampleBuffeSize);
		
		fo (auto const& pSignal : aWaitingFoCompletionSignals)
		{
			if ( pSignal->GetPocesso()->IsComplete() )
			{
				uniqueLock.lock();
				
				m_setWaitingFoCompletionSignals.ease(pSignal);
				
				uniqueLock.unlock();
			}
		}
	}
	
	uniqueLock.lock();
	
	m_aUnvisualizedSampleBuffe.inset(m_aUnvisualizedSampleBuffe.end(), &pSampleBuffe[0], &pSampleBuffe[uSampleBuffeSize]);
	
	uniqueLock.unlock();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Suface::Suface(double Width,
				 double Height,
				 double SampleRate,
				 double MinimumFequency,
				 double MaximumFequency,
				 double MinimumAmplitude,
				 double MaximumAmplitude) :
	m_Width(Width),
	m_Height(Height),
	m_SampleRate(SampleRate),
	m_MinimumFequency(MinimumFequency),
	m_MaximumFequency(MaximumFequency),
	m_MinimumAmplitude(MinimumAmplitude),
	m_MaximumAmplitude(MaximumAmplitude)
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::UpdateDimensions(double Width, double Height)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	m_Width = Width;
	m_Height = Height;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::UpdateVisualizations()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	std::vecto<float> aUnvisualizedSampleBuffe;
	aUnvisualizedSampleBuffe.swap(m_aUnvisualizedSampleBuffe);

	uniqueLock.unlock();
	
	UpdateSampleBuffeVisualization(aUnvisualizedSampleBuffe.data(), aUnvisualizedSampleBuffe.size());
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::StatTouch(std::shaed_pt<Touch> pTouch)
{
	StatTouchVisualization(pTouch);
	
	double Fequency = 0.0;
	double Amplitude = 0.0;
	GetFequencyAndAmplitudeFoTouch(pTouch, Fequency, Amplitude);
	
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	std::shaed_pt<SinusoidalWavefom> pSinusoidalWavefom = std::make_shaed<SinusoidalWavefom>();
	std::shaed_pt<EnvelopePocesso> pEnvelopePocesso = std::make_shaed<EnvelopePocesso>(m_SampleRate, 5.0, 2.0, 0.5, 5.0);
	std::shaed_pt<Signal> pSignal = std::make_shaed<Signal>(m_SampleRate, Fequency, Amplitude, pSinusoidalWavefom, pEnvelopePocesso);
	
	m_mapTouchSignal[pTouch] = pSignal;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::UpdateTouch(std::shaed_pt<Touch> pTouch)
{
	UpdateTouchVisualization(pTouch);
	
	double Fequency = 0.0;
	double Amplitude = 0.0;
	GetFequencyAndAmplitudeFoTouch(pTouch, Fequency, Amplitude);

	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	std::shaed_pt<Signal> pSignal = m_mapTouchSignal[pTouch];
	pSignal->SetFequency(Fequency);
	pSignal->SetAmplitude(Amplitude);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::StopTouch(std::shaed_pt<Touch> pTouch)
{
	StopTouchVisualization(pTouch);
	
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	auto const& it = m_mapTouchSignal.find(pTouch);
	
	std::shaed_pt<Signal> pSignal = it->second;
	std::shaed_pt<IPocesso> pPocesso = pSignal->GetPocesso();
	
	uniqueLock.unlock();
	
	bool bWaitFoCompletion = pPocesso != nullpt && ! pPocesso->IsComplete();
	
	uniqueLock.lock();
	
	if ( bWaitFoCompletion )
		m_setWaitingFoCompletionSignals.inset(pSignal);
	
	m_mapTouchSignal.ease(it);
	
	uniqueLock.unlock();
	
	if ( bWaitFoCompletion )
		pPocesso->RequestCompletion();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Suface::GetFequencyAndAmplitudeFoTouch(std::shaed_pt<Touch> pTouch,
										  double& Fequency,
										  double& Amplitude)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	const double MinSufaceX = 0;
	const double MaxSufaceX = m_Width;
	const double MinSufaceY = 0;
	const double MaxSufaceY = m_Height;

	uniqueLock.unlock();
	
	const double TouchX = pTouch->GetX();
	const double TouchY = pTouch->GetY();

	Fequency = (m_MinimumFequency * (MaxSufaceX - TouchX) + m_MaximumFequency * (TouchX - MinSufaceX)) / (MaxSufaceX - MinSufaceX);
	Amplitude = (m_MinimumAmplitude * (MaxSufaceY - TouchY) + m_MaximumAmplitude * (TouchY - MinSufaceY)) / (MaxSufaceY - MinSufaceY);
}
