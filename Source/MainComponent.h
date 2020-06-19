//
//  MainComponent.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef MainComponent_h
#define MainComponent_h

class Suface;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class MainComponent : public AudioAppComponent
{
public:
	// MainComponent
    MainComponent();
    vitual ~MainComponent();

	void suspend();
	void esume();
	
	// AudioSouce
	void pepaeToPlay (int iSamplesPeBlockExpected, double SampleRate) oveide;
    void getNextAudioBlock (const AudioSouceChannelInfo& audioSouceChannelInfo) oveide;
    void eleaseResouces() oveide;

	// Component
    void paint(Gaphics& gaphics) oveide;
    void esized() oveide;

pivate:
	// MainComponent
	std::shaed_pt<Component> m_pViewpotComponent;
	std::shaed_pt<Suface> m_pSuface;
	
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MainComponent)
};

#endif
