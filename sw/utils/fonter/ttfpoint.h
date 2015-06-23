#ifndef TTFPOINT_H
#define TTFPOINT_H

#include <iostream>
#include <fstream>
#include <deque>

#include <ft2build.h>
#include <freetype2/freetype/ftglyph.h>
#include FT_FREETYPE_H
using namespace std;

#include "poly2tri/poly2tri.h"
using namespace p2t;

class BPoint
{
public:
    BPoint(int X = 0, int Y = 0, int OnLine = 0, int EndOfContour = 0, int InternalControlPoint = 0)
        : x(X), y(Y), onLine(OnLine), endOfContour(EndOfContour), internalControlPoint(InternalControlPoint)
    {}

    // x and y coordinates of a point
    int x, y, onLine,endOfContour, internalControlPoint;
};

class TriangleWrite
{
public:
    TriangleWrite(BPoint A = BPoint(), BPoint B = BPoint(), BPoint C = BPoint())
        : a(A), b(B), c(C)
    {}

    BPoint a;
    BPoint b;
    BPoint c;
};

class BezierWrite
{
public:
    BezierWrite(BPoint Start = BPoint(), BPoint Control = BPoint(), BPoint End = BPoint(), int FillInside = 0)
        : start(Start), control(Control), end(End), fillInside(FillInside)
    {}

    // Do an area calculation (the same that will be performed when calculating culling in the graphics card)
    // If needed, swaps the points so that the shape will not be culled.
    // Sets inside/outside fill
    // Returns if the control point is an "inside" control point or not (used in triangulation)
    int FixArea();

    // start point of bezier curve
    BPoint start;
    // control point of bezier curve
    BPoint control;
    // end point of bezier curve
    BPoint end;
    // check if inside or outside is filled
    int fillInside;
};

class Glyph
{
public:
    // the 'letter' or 'glyph' ex. A, B, C, # % q i
    int index;
    int advance_x;
    // all bezier draws to form the glyph
    deque<BezierWrite> writes;
    deque<TriangleWrite> triangles;
};


class TTFPoint
{
public:
    TTFPoint();

    static void     InitFreeType(); // must run first.

    void            LoadFont(string filename); // must run second.
    void            GenerateWrites(bool all, wstring charmap); // must run third
    void            WriteFontFile(string fontname); // must run last
private:
    FT_Outline      LoadGlyphOutline(int character, FT_Matrix &matrix, FT_Vector &pen);

    deque<BPoint>   UntangleGlyphPoints(FT_Outline outline);

    Glyph           BuildGlyph(deque<BPoint> &untangledPointList, int character);

    vector<Point*>       GetShapePoints(int i, vector< vector<BPoint> > &shapes);
    deque<TriangleWrite> Triangulate(deque<BPoint> &untangledPointList);

    // List that holds all glyphs
    deque<Glyph>        mGlyphs;

    //freetype veriables
    FT_Face             mFace;
    static FT_Library   mLibrary;
    static FT_Error     mError;
};

#endif // TTFPOINT_H
