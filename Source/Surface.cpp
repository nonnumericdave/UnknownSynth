//
//  Surface.cpp
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#include "PrecompiledHeader.h"

#include "Surface.h"

#include "EnvelopeProcessor.h"
#include "Signal.h"
#include "SinusoidalWaveform.h"
#include "Touch.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
static Surface::PFN_Create g_pfnCreate = nullptr;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool
Surface::Register(PFN_Create pfnCreate)
{
	::g_pfnCreate = pfnCreate;
	
	return true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
std::shared_ptr<Surface>
Surface::Create(double rSampleRate,
				double rMinimumFrequency,
				double rMaximumFrequency,
				double rMinimumAmplitude,
				double rMaximumAmplitude)
{
	return
		::g_pfnCreate == nullptr ?
			nullptr :
			::g_pfnCreate(rSampleRate, rMinimumFrequency, rMaximumFrequency, rMinimumAmplitude, rMaximumAmplitude);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Surface::~Surface()
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::Start()
{
	StartSampleBufferVisualization();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::Stop()
{
	StopSampleBufferVisualization();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::UpdateSampleRate(double rSampleRate)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	m_rSampleRate = rSampleRate;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::GenerateNextSampleBuffer(float* prSampleBuffer, const std::size_t uSampleBufferSize)
{
	std::vector<std::shared_ptr<Signal> > aSignals;
	std::vector<std::shared_ptr<Signal> > aWaitingForCompletionSignals;
	
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	std::size_t uSignalCount = m_mapTouchSignal.size() + m_setWaitingForCompletionSignals.size();
	
	if ( uSignalCount == 0 )
	{
		uniqueLock.unlock();
		
		for (std::size_t uSampleBufferIndex = 0; uSampleBufferIndex < uSampleBufferSize; ++uSampleBufferIndex)
			prSampleBuffer[uSampleBufferIndex] = 0.0;
	}
	else
	{
		for (auto const& it : m_mapTouchSignal)
			aSignals.push_back(it.second);
		
		for (auto const& pSignal : m_setWaitingForCompletionSignals)
		{
			aSignals.push_back(pSignal);
			aWaitingForCompletionSignals.push_back(pSignal);
		}
		
		uniqueLock.unlock();
		
		aSignals[0]->GenerateNextSampleBuffer(prSampleBuffer, uSampleBufferSize);
		
		for (std::size_t uIndex = 1; uIndex < uSignalCount; ++uIndex)
			aSignals[uIndex]->AggregateNextSampleBuffer(prSampleBuffer, uSampleBufferSize);
		
		for (auto const& pSignal : aWaitingForCompletionSignals)
		{
			if ( pSignal->GetProcessor()->IsComplete() )
			{
				uniqueLock.lock();
				
				m_setWaitingForCompletionSignals.erase(pSignal);
				
				uniqueLock.unlock();
			}
		}
	}
	
	uniqueLock.lock();
	
	m_arUnvisualizedSampleBuffer.insert(m_arUnvisualizedSampleBuffer.end(), &prSampleBuffer[0], &prSampleBuffer[uSampleBufferSize]);
	
	uniqueLock.unlock();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Surface::Surface(double rWidth,
				 double rHeight,
				 double rSampleRate,
				 double rMinimumFrequency,
				 double rMaximumFrequency,
				 double rMinimumAmplitude,
				 double rMaximumAmplitude) :
	m_rWidth(rWidth),
	m_rHeight(rHeight),
	m_rSampleRate(rSampleRate),
	m_rMinimumFrequency(rMinimumFrequency),
	m_rMaximumFrequency(rMaximumFrequency),
	m_rMinimumAmplitude(rMinimumAmplitude),
	m_rMaximumAmplitude(rMaximumAmplitude)
{
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::UpdateDimensions(double rWidth, double rHeight)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	m_rWidth = rWidth;
	m_rHeight = rHeight;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::UpdateVisualizations()
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	std::vector<float> arUnvisualizedSampleBuffer;
	arUnvisualizedSampleBuffer.swap(m_arUnvisualizedSampleBuffer);

	uniqueLock.unlock();
	
	UpdateSampleBufferVisualization(arUnvisualizedSampleBuffer.data(), arUnvisualizedSampleBuffer.size());
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::StartTouch(std::shared_ptr<Touch> pTouch)
{
	StartTouchVisualization(pTouch);
	
	double rFrequency = 0.0;
	double rAmplitude = 0.0;
	GetFrequencyAndAmplitudeForTouch(pTouch, rFrequency, rAmplitude);
	
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	std::shared_ptr<SinusoidalWaveform> pSinusoidalWaveform = std::make_shared<SinusoidalWaveform>();
	std::shared_ptr<EnvelopeProcessor> pEnvelopeProcessor = std::make_shared<EnvelopeProcessor>(m_rSampleRate, 5.0, 2.0, 0.5, 5.0);
	std::shared_ptr<Signal> pSignal = std::make_shared<Signal>(m_rSampleRate, rFrequency, rAmplitude, pSinusoidalWaveform, pEnvelopeProcessor);
	
	m_mapTouchSignal[pTouch] = pSignal;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::UpdateTouch(std::shared_ptr<Touch> pTouch)
{
	UpdateTouchVisualization(pTouch);
	
	double rFrequency = 0.0;
	double rAmplitude = 0.0;
	GetFrequencyAndAmplitudeForTouch(pTouch, rFrequency, rAmplitude);

	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	std::shared_ptr<Signal> pSignal = m_mapTouchSignal[pTouch];
	pSignal->SetFrequency(rFrequency);
	pSignal->SetAmplitude(rAmplitude);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::StopTouch(std::shared_ptr<Touch> pTouch)
{
	StopTouchVisualization(pTouch);
	
	std::unique_lock<std::mutex> uniqueLock(m_mutex);

	auto const& it = m_mapTouchSignal.find(pTouch);
	
	std::shared_ptr<Signal> pSignal = it->second;
	std::shared_ptr<IProcessor> pProcessor = pSignal->GetProcessor();
	
	uniqueLock.unlock();
	
	bool bWaitForCompletion = pProcessor != nullptr && ! pProcessor->IsComplete();
	
	uniqueLock.lock();
	
	if ( bWaitForCompletion )
		m_setWaitingForCompletionSignals.insert(pSignal);
	
	m_mapTouchSignal.erase(it);
	
	uniqueLock.unlock();
	
	if ( bWaitForCompletion )
		pProcessor->RequestCompletion();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
Surface::GetFrequencyAndAmplitudeForTouch(std::shared_ptr<Touch> pTouch,
										  double& rFrequency,
										  double& rAmplitude)
{
	std::unique_lock<std::mutex> uniqueLock(m_mutex);
	
	const double rMinSurfaceX = 0;
	const double rMaxSurfaceX = m_rWidth;
	const double rMinSurfaceY = 0;
	const double rMaxSurfaceY = m_rHeight;

	uniqueLock.unlock();
	
	const double rTouchX = pTouch->GetX();
	const double rTouchY = pTouch->GetY();

	rFrequency = (m_rMinimumFrequency * (rMaxSurfaceX - rTouchX) + m_rMaximumFrequency * (rTouchX - rMinSurfaceX)) / (rMaxSurfaceX - rMinSurfaceX);
	rAmplitude = (m_rMinimumAmplitude * (rMaxSurfaceY - rTouchY) + m_rMaximumAmplitude * (rTouchY - rMinSurfaceY)) / (rMaxSurfaceY - rMinSurfaceY);
}
