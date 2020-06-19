//
//  Surface.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef Surface_h
#define Surface_h

class Signal;
class Touch;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Surface
{
public:
	// Surface
	typedef std::shared_ptr<Surface> (*PFN_Create)(double rSampleRate,
												   double rMinimumFrequency,
												   double rMaximumFrequency,
												   double rMinimumAmplitude,
												   double rMaximumAmplitude);
	
	static bool Register(PFN_Create pfnCreate);
	
	static std::shared_ptr<Surface> Create(double rSampleRate,
										   double rMinimumFrequency,
										   double rMaximumFrequency,
										   double rMinimumAmplitude,
										   double rMaximumAmplitude);
	
	virtual ~Surface();
	
	void Start();
	void Stop();
	
	void UpdateSampleRate(double rSampleRate);
	void GenerateNextSampleBuffer(float* prSampleBuffer, const std::size_t uSampleBufferSize);

	virtual std::shared_ptr<Component> GetComponent() = 0;

	virtual void Suspend() = 0;
	virtual void Resume() = 0;
	
protected:
	// Surface
	Surface(double rWidth,
			double rHeight,
			double rSampleRate,
			double rMinimumFrequency,
			double rMaximumFrequency,
			double rMinimumAmplitude,
			double rMaximumAmplitude);

	void UpdateDimensions(double rWidth, double rHeight);
	void UpdateVisualizations();
	
	void StartTouch(std::shared_ptr<Touch> pTouch);
	void UpdateTouch(std::shared_ptr<Touch> pTouch);
	void StopTouch(std::shared_ptr<Touch> pTouch);
	
	virtual void StartTouchVisualization(std::shared_ptr<Touch> pTouch) = 0;
	virtual void UpdateTouchVisualization(std::shared_ptr<Touch> pTouch) = 0;
	virtual void StopTouchVisualization(std::shared_ptr<Touch> pTouch) = 0;
	
	virtual void StartSampleBufferVisualization() = 0;
	virtual void UpdateSampleBufferVisualization(const float* prSampleBuffer, const std::size_t uSampleBufferSize) = 0;
	virtual void StopSampleBufferVisualization() = 0;
	
private:
	// Surface
	void GetFrequencyAndAmplitudeForTouch(std::shared_ptr<Touch> pTouch,
										  double& rFrequency,
										  double& rAmplitude);
	
	double m_rWidth;
	double m_rHeight;
	
	double m_rSampleRate;
	double m_rMinimumFrequency;
	double m_rMaximumFrequency;
	double m_rMinimumAmplitude;
	double m_rMaximumAmplitude;
	
	std::mutex m_mutex;
	std::map<std::shared_ptr<Touch>, std::shared_ptr<Signal> > m_mapTouchSignal;
	std::set<std::shared_ptr<Signal> > m_setWaitingForCompletionSignals;
	
	std::vector<float> m_arUnvisualizedSampleBuffer;
};

#endif
