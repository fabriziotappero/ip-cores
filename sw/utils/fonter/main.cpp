#include <iostream>
#include <deque>
#include <ft2build.h>
#include <freetype2/freetype/ftglyph.h>
#include FT_FREETYPE_H

#include "ttfpoint.h"

using namespace std;

int main(int argc,char** argv)
{
    if( argc < 2 )
    {
        cout << "Usage: " << argv[0] << " filename.ttf" << endl;
        return 1;
    }

    try
    {
        TTFPoint::InitFreeType();

        /* Open an output file */
        string		inFilename(argv[1]);

        TTFPoint points;
        points.LoadFont(inFilename);

        points.GenerateWrites(false, L"ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö");

        string fontname = inFilename.substr(0, inFilename.find('.'));
        fontname += "_font";

        points.WriteFontFile(fontname);

        return 0;
    }
    catch(int error)
    {
        cout << "Error code " << error << endl;
        return 1;
    }
}
