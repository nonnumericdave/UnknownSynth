//
//  IProcessor.h
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#ifndef IProcessor_h
#define IProcessor_h

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class IProcessor
{
public:
	// IProcessor
	virtual ~IProcessor() {}
	
	virtual void ProcessNextSampleBuffer(float* prSampleBuffer, std::size_t uSampleBufferSize) = 0;
	virtual void RequestCompletion() = 0;
	virtual bool IsComplete() = 0;
};

#endif
