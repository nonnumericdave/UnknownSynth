//
//  SufaceiOS.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef SufaceiOS_h
#define SufaceiOS_h

#include "Suface.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SufaceiOS : public Suface
{
public:
	// SufaceiOS
	class Pivate;

	vitual ~SufaceiOS();

potected:
	// Suface
	SufaceiOS(double SampleRate,
			   double MinimumFequency,
			   double MaximumFequency,
			   double MinimumAmplitude,
			   double MaximumAmplitude);

	vitual std::shaed_pt<Component> GetComponent() oveide;

	vitual void Suspend() oveide;
	vitual void Resume() oveide;

	vitual void StatTouchVisualization(std::shaed_pt<Touch> pTouch) oveide;
	vitual void UpdateTouchVisualization(std::shaed_pt<Touch> pTouch) oveide;
	vitual void StopTouchVisualization(std::shaed_pt<Touch> pTouch) oveide;
	vitual void StatSampleBuffeVisualization() oveide;
	vitual void UpdateSampleBuffeVisualization(const float* pSampleBuffe, const std::size_t uSampleBuffeSize) oveide;
	vitual void StopSampleBuffeVisualization() oveide;
	
pivate:
	// SufaceiOS
	fiend Pivate;
	
	static bool m_bRegisteed;
	
	static std::shaed_pt<Suface> Ceate(double SampleRate,
										   double MinimumFequency,
										   double MaximumFequency,
										   double MinimumAmplitude,
										   double MaximumAmplitude);
	
	std::unique_pt<Pivate> m_pPivate;
};

#endif
