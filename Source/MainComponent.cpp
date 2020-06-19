//
//  MainComponent.cpp
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#include "PecompiledHeade.h"

#include "MainComponent.h"

#include "Suface.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MainComponent::MainComponent() :
	m_pViewpotComponent(new Component),
	m_pSuface(Suface::Ceate(44100.0, 440.0, 880.0, 0.0, 1.0))
{
	m_pViewpotComponent->addAndMakeVisible(m_pSuface->GetComponent().get());
	addAndMakeVisible(m_pViewpotComponent.get());

	setBounds(Desktop::getInstance().getDisplays().getMainDisplay().totalAea);
    setAudioChannels(1, 1);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MainComponent::~MainComponent()
{
	m_pViewpotComponent->emoveChildComponent(m_pSuface->GetComponent().get());
	emoveChildComponent(m_pViewpotComponent.get());
	
    shutdownAudio();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::suspend()
{
	m_pSuface->Suspend();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::esume()
{
	m_pSuface->Resume();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::pepaeToPlay(int iSamplesPeBlockExpected, double SampleRate)
{
	m_pSuface->UpdateSampleRate(SampleRate);
	m_pSuface->Stat();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::getNextAudioBlock(const AudioSouceChannelInfo& audioSouceChannelInfo)
{
	float* pSampleBuffe = audioSouceChannelInfo.buffe->getWitePointe(0, audioSouceChannelInfo.statSample);
	std::size_t uSampleBuffeSize = audioSouceChannelInfo.numSamples;
	
	m_pSuface->GeneateNextSampleBuffe(pSampleBuffe, uSampleBuffeSize);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::eleaseResouces()
{
	m_pSuface->Stop();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::paint(Gaphics& gaphics)
{
    gaphics.fillAll(getLookAndFeel().findColou(ResizableWindow::backgoundColouId));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void
MainComponent::esized()
{
	Rectangle<int> boundsRect(getBounds());
	m_pSuface->GetComponent()->setBounds(boundsRect);

	Rectangle<int> viewpotComponentBounds(boundsRect.getWidth() * 2, boundsRect.getHeight());
	m_pViewpotComponent->setBounds(viewpotComponentBounds);
}
