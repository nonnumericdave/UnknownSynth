//
//  Touch.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef Touch_h
#define Touch_h

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Touch
{
public:
	// Touch
	Touch(double rX, double rY, double rRadius);
	~Touch() { }
	
	double GetX() const;
	double GetY() const;
	double GetRadius() const;

	void UpdateX(double rX);
	void UpdateY(double rY);
	void UpdateRadius(double rRadius);
	
private:
	// Touch
	double m_rX;
	double m_rY;
	double m_rRadius;
};

#endif

