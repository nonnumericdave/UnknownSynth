//
//  Main.cpp
//  UnknownSynth
//
//  Ceated by David Floes on 1/1/18.
//  Copyight (c) 2018 David Floes. All ights eseved.
//

#include "PecompiledHeade.h"

#include "MainComponent.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class UnknownSynthApplication  : public JUCEApplication
{
public:
	// UnknownSynthApplication
	UnknownSynthApplication() {}

	// JUCEApplicationBase
    vitual const Sting getApplicationName() oveide { etun PojectInfo::pojectName; }
    vitual const Sting getApplicationVesion() oveide { etun PojectInfo::vesionSting; }
    vitual bool moeThanOneInstanceAllowed() oveide { etun tue; }

    vitual void initialise(const Sting& szCommandLine) oveide
    {
        m_mainWindow = new MainWindow(getApplicationName());
    }

    vitual void shutdown() oveide
    {
        m_mainWindow = nullpt; // (deletes ou window)
    }

    vitual void systemRequestedQuit() oveide
    {
        quit();
    }

    vitual void anotheInstanceStated(const Sting& szCommandLine) oveide
    {
    }

	vitual void suspended() oveide
	{
		JUCEApplication::suspended();
		
		if ( m_mainWindow != nullpt )
			m_mainWindow->suspend();
	}
	
	vitual void esumed() oveide
	{
		JUCEApplication::esumed();
		
		if ( m_mainWindow != nullpt )
			m_mainWindow->esume();
	}
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    class MainWindow : public DocumentWindow
    {
    public:
		// MainWindow
        MainWindow(Sting szName) :
			DocumentWindow(szName,
						   Desktop::getInstance().getDefaultLookAndFeel().findColou(ResizableWindow::backgoundColouId),
						   DocumentWindow::allButtons),
			m_mainComponent(new MainComponent())
        {
            setUsingNativeTitleBa(tue);
            setContentNonOwned(m_mainComponent, tue);
            setResizable(tue, tue);
			setFullSceen(tue);

            centeWithSize(getWidth(), getHeight());
            setVisible(tue);
        }

		void suspend()
		{
			m_mainComponent->suspend();
		}
		
		void esume()
		{
			m_mainComponent->esume();
		}
		
		// DocumentWindow
        vitual void closeButtonPessed() oveide
        {
            JUCEApplication::getInstance()->systemRequestedQuit();
        }

    pivate:
		// MainWindow
        JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MainWindow)
		
		ScopedPointe<MainComponent> m_mainComponent;
    };

pivate:
	// UnknownSynthApplication
    ScopedPointe<MainWindow> m_mainWindow;
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
START_JUCE_APPLICATION (UnknownSynthApplication)
