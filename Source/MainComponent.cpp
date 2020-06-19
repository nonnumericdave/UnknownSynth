//
//  MainComponent.cpp
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#include "PrecompiledHeader.h"

#include "MainComponent.h"

#include "Surface.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MainComponent::MainComponent() :
	m_pViewportComponent(new Component),
	m_pSurface(Surface::Create(44100.0, 440.0, 880.0, 0.0, 1.0))
{
	m_pViewportComponent->addAndMakeVisible(m_pSurface->GetComponent().get());
	addAndMakeVisible(m_pViewportComponent.get());

	setBounds(Desktop::getInstance().getDisplays().getMainDisplay().totalArea);
    setAudioChannels(1, 1);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MainComponent::~MainComponent()
{
	m_pViewportComponent->removeChildComponent(m_pSurface->GetComponent().get());
	removeChildComponent(m_pViewportComponent.get());
	
    shutdownAudio();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::suspend()
{
	m_pSurface->Suspend();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::resume()
{
	m_pSurface->Resume();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::prepareToPlay(int iSamplesPerBlockExpected, double rSampleRate)
{
	m_pSurface->UpdateSampleRate(rSampleRate);
	m_pSurface->Start();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::getNextAudioBlock(const AudioSourceChannelInfo& audioSourceChannelInfo)
{
	float* prSampleBuffer = audioSourceChannelInfo.buffer->getWritePointer(0, audioSourceChannelInfo.startSample);
	std::size_t uSampleBufferSize = audioSourceChannelInfo.numSamples;
	
	m_pSurface->GenerateNextSampleBuffer(prSampleBuffer, uSampleBufferSize);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::releaseResources()
{
	m_pSurface->Stop();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::paint(Graphics& graphics)
{
    graphics.fillAll(getLookAndFeel().findColour(ResizableWindow::backgroundColourId));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::resized()
{
	Rectangle<int> boundsRect(getBounds());
	m_pSurface->GetComponent()->setBounds(boundsRect);

	Rectangle<int> viewportComponentBounds(boundsRect.getWidth() * 2, boundsRect.getHeight());
	m_pViewportComponent->setBounds(viewportComponentBounds);
}
