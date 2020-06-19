//
//  IWavefom.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef IWavefom_h
#define IWavefom_h

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class IWavefom
{
public:
	// IWavefom
	vitual ~IWavefom() {}
	
	vitual void GeneateSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize, double Amplitude, double CyclePhase, double CyclePhaseDelta) = 0;
	vitual void AggegateSampleBuffe(float* pSampleBuffe, std::size_t uSampleBuffeSize, double Amplitude, double CyclePhase, double CyclePhaseDelta) = 0;
};

#endif
