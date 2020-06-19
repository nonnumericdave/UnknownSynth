//
//  MainComponent.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef MainComponent_h
#define MainComponent_h

class Surface;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class MainComponent : public AudioAppComponent
{
public:
	// MainComponent
    MainComponent();
    virtual ~MainComponent();

	void suspend();
	void resume();
	
	// AudioSource
	void prepareToPlay (int iSamplesPerBlockExpected, double rSampleRate) override;
    void getNextAudioBlock (const AudioSourceChannelInfo& audioSourceChannelInfo) override;
    void releaseResources() override;

	// Component
    void paint(Graphics& graphics) override;
    void resized() override;

private:
	// MainComponent
	std::shared_ptr<Component> m_pViewportComponent;
	std::shared_ptr<Surface> m_pSurface;
	
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MainComponent)
};

#endif
