................................................................................

Running Connect-k on Windows
----------------------------

To run the program, you must install the GTK runtime available here:
http://gimp-win.sourceforge.net/stable.html


Compiling Connect-k on Windows
------------------------------

The project file is setup for compilation with Microsoft Visual Studio 2003.
This project file should be importable into later versions of Visual Studio
without issues.

To compile, you must have the GTK Windows development SDK installed and have
configured your environment settings correctly. The SDK is available here:
http://www.gimp.org/~tml/gimp/win32/

Download all development zips (*-dev, ~30mb) and extract them into a folder on
your computer. Configure Visual Studio to use the SDK by opening:
Tools -> Options -> Projects -> VC++ Directories
        
Add all of the GTK include folders as well as the include folder itself to
the Included Files list. Add the GTK lib directory to the Library Files list.

SVG screenshots are not available for Windows because the Cairo version is
not up to date.