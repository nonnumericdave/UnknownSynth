//
//  Touch.h
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#ifndef Touch_h
#define Touch_h

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Touch
{
public:
	// Touch
	Touch(double X, double Y, double Radius);
	~Touch() { }
	
	double GetX() const;
	double GetY() const;
	double GetRadius() const;

	void UpdateX(double X);
	void UpdateY(double Y);
	void UpdateRadius(double Radius);
	
pivate:
	// Touch
	double m_X;
	double m_Y;
	double m_Radius;
};

#endif

