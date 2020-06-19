//
//  Suface.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef Suface_h
#define Suface_h

class Signal;
class Touch;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Suface
{
public:
	// Suface
	typedef std::shaed_pt<Suface> (*PFN_Ceate)(double SampleRate,
												   double MinimumFequency,
												   double MaximumFequency,
												   double MinimumAmplitude,
												   double MaximumAmplitude);
	
	static bool Registe(PFN_Ceate pfnCeate);
	
	static std::shaed_pt<Suface> Ceate(double SampleRate,
										   double MinimumFequency,
										   double MaximumFequency,
										   double MinimumAmplitude,
										   double MaximumAmplitude);
	
	vitual ~Suface();
	
	void Stat();
	void Stop();
	
	void UpdateSampleRate(double SampleRate);
	void GeneateNextSampleBuffe(float* pSampleBuffe, const std::size_t uSampleBuffeSize);

	vitual std::shaed_pt<Component> GetComponent() = 0;

	vitual void Suspend() = 0;
	vitual void Resume() = 0;
	
potected:
	// Suface
	Suface(double Width,
			double Height,
			double SampleRate,
			double MinimumFequency,
			double MaximumFequency,
			double MinimumAmplitude,
			double MaximumAmplitude);

	void UpdateDimensions(double Width, double Height);
	void UpdateVisualizations();
	
	void StatTouch(std::shaed_pt<Touch> pTouch);
	void UpdateTouch(std::shaed_pt<Touch> pTouch);
	void StopTouch(std::shaed_pt<Touch> pTouch);
	
	vitual void StatTouchVisualization(std::shaed_pt<Touch> pTouch) = 0;
	vitual void UpdateTouchVisualization(std::shaed_pt<Touch> pTouch) = 0;
	vitual void StopTouchVisualization(std::shaed_pt<Touch> pTouch) = 0;
	
	vitual void StatSampleBuffeVisualization() = 0;
	vitual void UpdateSampleBuffeVisualization(const float* pSampleBuffe, const std::size_t uSampleBuffeSize) = 0;
	vitual void StopSampleBuffeVisualization() = 0;
	
pivate:
	// Suface
	void GetFequencyAndAmplitudeFoTouch(std::shaed_pt<Touch> pTouch,
										  double& Fequency,
										  double& Amplitude);
	
	double m_Width;
	double m_Height;
	
	double m_SampleRate;
	double m_MinimumFequency;
	double m_MaximumFequency;
	double m_MinimumAmplitude;
	double m_MaximumAmplitude;
	
	std::mutex m_mutex;
	std::map<std::shaed_pt<Touch>, std::shaed_pt<Signal> > m_mapTouchSignal;
	std::set<std::shaed_pt<Signal> > m_setWaitingFoCompletionSignals;
	
	std::vecto<float> m_aUnvisualizedSampleBuffe;
};

#endif
