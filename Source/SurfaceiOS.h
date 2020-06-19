//
//  SurfaceiOS.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef SurfaceiOS_h
#define SurfaceiOS_h

#include "Surface.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SurfaceiOS : public Surface
{
public:
	// SurfaceiOS
	class Private;

	virtual ~SurfaceiOS();

protected:
	// Surface
	SurfaceiOS(double rSampleRate,
			   double rMinimumFrequency,
			   double rMaximumFrequency,
			   double rMinimumAmplitude,
			   double rMaximumAmplitude);

	virtual std::shared_ptr<Component> GetComponent() override;

	virtual void Suspend() override;
	virtual void Resume() override;

	virtual void StartTouchVisualization(std::shared_ptr<Touch> pTouch) override;
	virtual void UpdateTouchVisualization(std::shared_ptr<Touch> pTouch) override;
	virtual void StopTouchVisualization(std::shared_ptr<Touch> pTouch) override;
	virtual void StartSampleBufferVisualization() override;
	virtual void UpdateSampleBufferVisualization(const float* prSampleBuffer, const std::size_t uSampleBufferSize) override;
	virtual void StopSampleBufferVisualization() override;
	
private:
	// SurfaceiOS
	friend Private;
	
	static bool m_bRegistered;
	
	static std::shared_ptr<Surface> Create(double rSampleRate,
										   double rMinimumFrequency,
										   double rMaximumFrequency,
										   double rMinimumAmplitude,
										   double rMaximumAmplitude);
	
	std::unique_ptr<Private> m_pPrivate;
};

#endif
