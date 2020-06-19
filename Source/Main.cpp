//
//  Main.cpp
//  UnknownSynth
//
//  Created by David Flores on 1/1/18.
//  Copyright (c) 2018 David Flores. All rights reserved.
//

#include "PrecompiledHeader.h"

#include "MainComponent.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class UnknownSynthApplication  : public JUCEApplication
{
public:
	// UnknownSynthApplication
	UnknownSynthApplication() {}

	// JUCEApplicationBase
    virtual const String getApplicationName() override { return ProjectInfo::projectName; }
    virtual const String getApplicationVersion() override { return ProjectInfo::versionString; }
    virtual bool moreThanOneInstanceAllowed() override { return true; }

    virtual void initialise(const String& szCommandLine) override
    {
        m_mainWindow = new MainWindow(getApplicationName());
    }

    virtual void shutdown() override
    {
        m_mainWindow = nullptr; // (deletes our window)
    }

    virtual void systemRequestedQuit() override
    {
        quit();
    }

    virtual void anotherInstanceStarted(const String& szCommandLine) override
    {
    }

	virtual void suspended() override
	{
		JUCEApplication::suspended();
		
		if ( m_mainWindow != nullptr )
			m_mainWindow->suspend();
	}
	
	virtual void resumed() override
	{
		JUCEApplication::resumed();
		
		if ( m_mainWindow != nullptr )
			m_mainWindow->resume();
	}
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    class MainWindow : public DocumentWindow
    {
    public:
		// MainWindow
        MainWindow(String szName) :
			DocumentWindow(szName,
						   Desktop::getInstance().getDefaultLookAndFeel().findColour(ResizableWindow::backgroundColourId),
						   DocumentWindow::allButtons),
			m_mainComponent(new MainComponent())
        {
            setUsingNativeTitleBar(true);
            setContentNonOwned(m_mainComponent, true);
            setResizable(true, true);
			setFullScreen(true);

            centreWithSize(getWidth(), getHeight());
            setVisible(true);
        }

		void suspend()
		{
			m_mainComponent->suspend();
		}
		
		void resume()
		{
			m_mainComponent->resume();
		}
		
		// DocumentWindow
        virtual void closeButtonPressed() override
        {
            JUCEApplication::getInstance()->systemRequestedQuit();
        }

    private:
		// MainWindow
        JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MainWindow)
		
		ScopedPointer<MainComponent> m_mainComponent;
    };

private:
	// UnknownSynthApplication
    ScopedPointer<MainWindow> m_mainWindow;
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
START_JUCE_APPLICATION (UnknownSynthApplication)
