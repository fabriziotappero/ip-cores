#include "ttfpoint.h"

FT_Library  TTFPoint::mLibrary;
FT_Error    TTFPoint::mError;

TTFPoint::TTFPoint()
{
}

void TTFPoint::InitFreeType()
{
    // intit freetype
    mError = FT_Init_FreeType( &mLibrary );
    if(mError)
    {
        cout << "Error loading freetype" << endl;
        throw mError;
    }
}

void TTFPoint::LoadFont(string filename)
{
    // open font
    mError = FT_New_Face( mLibrary,filename.c_str(),0,&mFace );
    if(mError)
    {
        cout << "Error loading font" << endl;
        throw mError;
    }


    // set the fontSize
    FT_F26Dot6 font_size = 100;
    mError = FT_Set_Char_Size( mFace, font_size, font_size, 72, 72 );
    if(mError)
    {
        cout << "error setting char size" << endl;
        throw mError;
    }

    cout << "Font: " << filename << " Loaded with " << mFace->num_glyphs << " Glyphs " << endl;
}

int BezierWrite::FixArea()
{
    //float area = (p1.x - p0.x)*(p2.y-p0.y) - (p2.x-p0.x)*(p1.y-p0.y);
    float area = (control.x - start.x)*(end.y-start.y) - (end.x-start.x)*(control.y-start.y);
    if(area < 0)
    {
        // outside
        fillInside = 0;
        swap(start, end);
        return 1;
    }
    else
    {
        // inside
        fillInside = 1;
        return 0;
    }
}

FT_Outline TTFPoint::LoadGlyphOutline(int character, FT_Matrix &matrix, FT_Vector &pen)
{
    FT_UInt glyph_index = FT_Get_Char_Index( mFace,  character );
    cout << "<Get glyph " << character << " with glyph_index " << glyph_index;

    FT_Set_Transform( mFace, &matrix, &pen );
    // load glyph
    mError = FT_Load_Glyph(mFace,glyph_index,FT_LOAD_NO_SCALE);
    if(mError)
    {
        cout << "Failed to load glyph!" << endl;
        throw mError;
    }

    FT_GlyphSlot slot = mFace->glyph;
    FT_Outline outline = slot->outline;
    cout << " and " << outline.n_contours << " outlines and " << outline.n_points << " points. ";

    return outline;
}

Glyph TTFPoint::BuildGlyph(deque<BPoint> &untangledPointList, int character)
{
    Glyph current_glyph;
    current_glyph.index = character;
    current_glyph.advance_x = mFace->glyph->advance.x;

    int firstObject = 0;
    for(unsigned int j=0; j<untangledPointList.size(); j++)
    {
        int end_first=0, end_second=0, end_third=0;
        int line_first=0, line_second=0, line_third=0;

        // generate write
        if( j+2 < untangledPointList.size()) // if we got more then three left in list
        {
            if(untangledPointList[j].endOfContour)
                end_first = 1;
            if(untangledPointList[j+1].endOfContour)
                end_second = 1;
            if(untangledPointList[j+2].endOfContour)
                end_third = 1;

            if(untangledPointList[j].onLine)
                line_first = 1;
            if(untangledPointList[j+1].onLine)
                line_second = 1;
            if(untangledPointList[j+2].onLine)
                line_third = 1;

            if(!end_first && !end_second && !end_third) // if no point is the end of the shape.
            {
                if(line_first && !line_second && line_third) // if first and last are points and middle is control point
                {
                    BezierWrite write(untangledPointList[j],
                                      untangledPointList[j+1],
                                      untangledPointList[j+2]);
                    untangledPointList[j+1].internalControlPoint = write.FixArea();
                    current_glyph.writes.push_back(write);
                    j++; // skip check of control point. go directly to end point.
                }
                else if(line_first && line_second) // if booth lines is online.
                {
                    continue; // do nothing
                }
            }
            if(end_first) // if first point is a endpoint
            {
                untangledPointList[j].internalControlPoint = 1; // mark end of shape for triangulation
                if(line_first) // if point is online
                {
                    //  cout << "End of shape, first & online ";
                    if(untangledPointList[firstObject].onLine) // if two on in row, continue.
                        continue;
                    if(untangledPointList[firstObject+1].onLine) // if on, off, on, do write
                    {
                        BezierWrite write(untangledPointList[j],
                                          untangledPointList[firstObject],
                                          untangledPointList[firstObject+1]);

                        untangledPointList[j+1].internalControlPoint = write.FixArea();
                        current_glyph.writes.push_back(write);
                        firstObject = j+2; // new first object in new shape.
                        //     cout << "Done" << endl;
                    }
                    // else
                    //     cout << "Not Done" << endl;
                }
                else // end of shape is a control point!
                {
                    //    cout << "End of shape, first & offline: ";
                    if(untangledPointList[firstObject].onLine) // if two on in row, continue.
                    {
                        BezierWrite write(untangledPointList[j],
                                          untangledPointList[j+1],
                                          untangledPointList[firstObject]);

                        untangledPointList[j+1].internalControlPoint = write.FixArea();
                        current_glyph.writes.push_back(write);
                        firstObject = j+2; // new first object in new shape.
                        //       cout << "Done" << endl;
                    }
                    //   else
                    //        cout << "Not done" << endl;
                }
            }
            if(end_second) // if second point is a endpoint
            {
                untangledPointList[j+1].internalControlPoint = 1; // mark end of shape for triangulation

                if(line_second) // if point is online
                {
                    //   cout << "End of shape, second & online ";
                    if(untangledPointList[firstObject].onLine) // if two on in row, continue.
                        continue;
                    if(untangledPointList[firstObject+1].onLine) // if on, off, on, do write
                    {
                        BezierWrite write(untangledPointList[j+1],
                                          untangledPointList[firstObject],
                                          untangledPointList[firstObject+1]);

                        untangledPointList[j+1].internalControlPoint = write.FixArea();
                        current_glyph.writes.push_back(write);
                        firstObject = j+2; // new first object in new shape.
                        //      cout << "Done"  << endl;
                    }
                    //  cout << "Not Done" << endl;
                }
                else // end of shape is a control point!
                {
                    // will this happen?
                    //  cout << "End of shape, second & offline ";
                    if(untangledPointList[firstObject].onLine)
                    {
                        BezierWrite write(untangledPointList[j],
                                          untangledPointList[j+1],
                                          untangledPointList[firstObject]);

                        untangledPointList[j+1].internalControlPoint = write.FixArea();
                        current_glyph.writes.push_back(write);
                        firstObject = j+2; // new first object in new shape.
                        j++;
                        //      cout << "Done"  << endl;
                    }
                    // else
                    //    cout << "Not Done" << endl;
                }

            }
            if(end_third) // if third point is a endpoint
            {
                untangledPointList[j+2].internalControlPoint = 1; // mark end of shape for triangulation
                if(line_third) // if point is online
                {
                    // do nothing, itterate two steps and try again!
                    //    cout << "End of shape, third & online" << endl;
                }
                else // end of shape is a control point!
                {
                    // will this happen?
                    //      cout << "End of shape, third & offline" << endl;
                }
            }
        }
        else if( j+2 == untangledPointList.size()) // if we got two points left
        {
            if(untangledPointList[j].endOfContour)
                end_first = 1;
            if(untangledPointList[j+1].endOfContour)
                end_second = 1;

            if(untangledPointList[j].onLine)
                line_first = 1;
            if(untangledPointList[j+1].onLine)
                line_second = 1;

            if(end_first)
            {
                untangledPointList[j].internalControlPoint = 1; // mark end of shape for triangulation
                if(line_first)
                {
                    // cout << "small End of shape, first & online ";
                    if(untangledPointList[firstObject].onLine) // if two on in row, continue.
                        continue;
                    if(untangledPointList[firstObject+1].onLine) // if on, off, on, do write
                    {
                        BezierWrite write(untangledPointList[j],
                                          untangledPointList[firstObject],
                                          untangledPointList[firstObject+1]);

                        untangledPointList[j+1].internalControlPoint = write.FixArea();
                        current_glyph.writes.push_back(write);
                        firstObject = j+1; // new first object in new shape.
                        //     cout << "Done" << endl;
                    }
                    // else
                    //    cout << "Not Done" << endl;
                }
                else
                {
                    // cout << "small End of shape, first & offline: ";
                    if(untangledPointList[firstObject].onLine) // if two on in row, continue.
                    {
                        BezierWrite write(untangledPointList[j],
                                          untangledPointList[j+1],
                                          untangledPointList[firstObject]);

                        untangledPointList[j+1].internalControlPoint = write.FixArea();
                        current_glyph.writes.push_back(write);
                        firstObject = j+1; // new first object in new shape.
                        //    cout << "Done" << endl;
                    }
                    //else
                    //    cout << "Not done" << endl;
                }

            }
            else if(end_second)
            {
                untangledPointList[j+1].internalControlPoint = 1; // mark end of shape for triangulation
                if(line_second)
                {
                    //cout << "small End of shape, second & online ";
                    if(untangledPointList[firstObject].onLine) // if two on in row, continue.
                        continue;
                    if(untangledPointList[firstObject+1].onLine) // if on, off, on, do write
                    {
                        BezierWrite write(untangledPointList[j+1],
                                          untangledPointList[firstObject],
                                          untangledPointList[firstObject+1]);

                        untangledPointList[j+1].internalControlPoint = write.FixArea();
                        current_glyph.writes.push_back(write);
                        firstObject = 0; // new first object in new shape.
                        //   cout << "Done"  << endl;
                    }
                    //cout << "Not Done" << endl;
                }
                else
                {
                    //  cout << "small End of shape, second & offline ";
                    if(untangledPointList[firstObject].onLine)
                    {
                        BezierWrite write(untangledPointList[j],
                                          untangledPointList[j+1],
                                          untangledPointList[firstObject]);

                        untangledPointList[j+1].internalControlPoint = write.FixArea();
                        current_glyph.writes.push_back(write);
                        firstObject = 0; // new first object in new shape.
                        j++;
                        //  cout << "Done"  << endl;
                    }
                    //else
                    //  cout << "Not Done" << endl;
                }
            }

        }
        else if( j+1 == untangledPointList.size()) // if we got one point left
        {
            if(untangledPointList[j].endOfContour)
                end_first = 1;

            if(untangledPointList[j].onLine)
                line_first = 1;
        }
    }

    // triangulate and assign to current_glyph.
    current_glyph.triangles = Triangulate(untangledPointList);

    return current_glyph;
}

void TTFPoint::GenerateWrites(bool all, wstring charmap)
{
    if(all)
    {
        //save complete font
        cout << "<COPY ALL NOT IMPLEMENTED YET!>" << endl;
        throw 1;
    }

    FT_Matrix     matrix;                 // transformation matrix
    FT_Vector     pen;                    // untransformed origin

    // set up matrix
    matrix.xx = (FT_Fixed)(1 * 0x10000L );
    matrix.xy = (FT_Fixed)(0 * 0x10000L );
    matrix.yx = (FT_Fixed)(0 * 0x10000L );
    matrix.yy = (FT_Fixed)(-1 * 0x10000L );

    // the pen position in 26.6 cartesian space coordinates;
    // start at (300,200) relative to the upper left corner
    pen.x = 0;
    pen.y = 0;

    //save selected characters
    for(unsigned int i=0; i<charmap.size(); i++)
    {
        // Get the outline
        FT_Outline outline = LoadGlyphOutline(charmap[i], matrix, pen);

        deque<BPoint> untangledPointList = UntangleGlyphPoints(outline);

        cout << " Untangled: " << untangledPointList.size() << " from " << outline.n_points << " points>" << endl;

        mGlyphs.push_back(BuildGlyph(untangledPointList, charmap[i]));
    }
}

deque<BPoint> TTFPoint::UntangleGlyphPoints(FT_Outline outline)
{
    deque<BPoint> untangledPointList;
    bool last_off = false;

    BPoint lastPoint(-60000, -60000);

    for(int i=0; i<outline.n_points; i++)
    {
        if(outline.points[i].x == lastPoint.x && outline.points[i].y == lastPoint.y)
            continue;
        lastPoint.x = outline.points[i].x;
        lastPoint.y = outline.points[i].y;

        if(outline.tags[i] == 0x001) // on line
        {
            untangledPointList.push_back(BPoint(outline.points[i].x,
                                                outline.points[i].y,
                                                1));

            // last point was on line
            last_off = false;
        }
        else // off point
        {
            // if last was off and this is off, then there is a implicit point inbetween.
            if(last_off)
            {
                // Applying the midpoint formula to calculate implicit midpoint

                // (x0 + x1)       | (y0 + y1)
                // --------- = x   | --------- = y
                //     2           |     2

                int x = (outline.points[i-1].x + outline.points[i].x) / 2;
                int y = (outline.points[i-1].y + outline.points[i].y) / 2;

                // add implicit online point to list.
                untangledPointList.push_back(BPoint(x, y, 1));

                bool endOfContour = false;
                // check if this point is the endpoint of a shape.
                for(int j=0; j<outline.n_contours; j++)
                {
                    if(outline.contours[j] == i)
                    {
                        endOfContour = true;
                        break;
                    }
                }

                // add explicit offline point to list
                untangledPointList.push_back(BPoint(outline.points[i].x,
                                                    outline.points[i].y,
                                                    0, endOfContour));
            }
            else // this is the first point off curve.
            {
                bool endOfContour = false;
                // check if this point is the endpoint of a shape.
                for(int j=0; j<outline.n_contours; j++)
                {
                    if(outline.contours[j] == i)
                    {
                        endOfContour = true;
                        break;
                    }
                }

                untangledPointList.push_back(BPoint(outline.points[i].x,
                                                    outline.points[i].y,
                                                    0, endOfContour));

                //last point was off
                last_off = true;
            }
        }
    }

    return untangledPointList;
}

void TTFPoint::WriteFontFile(string fontname)
{
    string filename	= fontname + ".h";

    ofstream	output(filename.c_str(),ofstream::out);
    if( !output )
    {
        cout << "Couldn't open output file!" << endl;
        throw 2;
    }

    output << "#ifndef " << fontname << "_H" << endl;
    output << "#define " << fontname << "_H" << endl << endl;
    output << "#include \"orgfx_vector_font.h\"" << endl << endl;

    output << "orgfx_vector_font init_" << fontname << "();" << endl << endl;

    output << "Glyph* " << fontname << "_glyphindexlist[256];" << endl << endl;

    // write data to file
    for(unsigned int i=0; i < mGlyphs.size(); i++)
    {
        // GLYPH DATA
        output << "//Glyph: " << mGlyphs[i].index << endl;
        output << "int          " << fontname << "_glyph_" << mGlyphs[i].index << "_index     = " << mGlyphs[i].index         << "; " << endl;
        output << "int          " << fontname << "_glyph_" << mGlyphs[i].index << "_advance_x = " << mGlyphs[i].advance_x     << "; " << endl;
        output << "int          " << fontname << "_glyph_" << mGlyphs[i].index << "_size      = " << mGlyphs[i].writes.size() << ";" << endl;
        output << "Bezier_write " << fontname << "_glyph_" << mGlyphs[i].index << "[]         = {" << endl;
        for(unsigned int j=0; j<mGlyphs[i].writes.size(); j++)
        {
            output << "{{"
                   << mGlyphs[i].writes[j].start.x   << ", " <<  mGlyphs[i].writes[j].start.y   << "}, {"
                   << mGlyphs[i].writes[j].control.x << ", " <<  mGlyphs[i].writes[j].control.y << "}, {"
                   << mGlyphs[i].writes[j].end.x     << ", " <<  mGlyphs[i].writes[j].end.y     << "},"
                   << mGlyphs[i].writes[j].fillInside << " }";
            output << "," << endl;
        }
        output << "};" << endl;

        // TRIANGLE DATA
        output << "int            " << fontname << "_glyph_" << mGlyphs[i].index << "_triangle_size = " << mGlyphs[i].triangles.size() << ";" << endl;
        output << "Triangle_write " << fontname << "_glyph_" << mGlyphs[i].index << "_triangles[]   = {" << endl;
        for(unsigned int j=0; j<mGlyphs[i].triangles.size(); j++)
        {
            output << "{{"
                   << mGlyphs[i].triangles[j].a.x << ", " <<  mGlyphs[i].triangles[j].a.y << "}, {"
                   << mGlyphs[i].triangles[j].b.x << ", " <<  mGlyphs[i].triangles[j].b.y << "}, {"
                   << mGlyphs[i].triangles[j].c.x << ", " <<  mGlyphs[i].triangles[j].c.y << "}}";
            output << "," << endl;
        }
        output << "};" << endl;


    }

    output << "int " << fontname << "_nGlyphs = " << mGlyphs.size() << ";" << endl << endl;
    output << "Glyph " << fontname << "_glyphlist[" << mGlyphs.size() << "];" << endl << endl;
    output << "void generate_" << fontname << "()" << endl;
    output << "{" << endl;
    output << "    Glyph pGlyph;" << endl;

    for(unsigned int i=0; i< mGlyphs.size(); i++)
    {
        output << "    pGlyph.index             = " << fontname << "_glyph_" << mGlyphs[i].index << "_index;" << endl;
        output << "    pGlyph.advance_x         = " << fontname << "_glyph_" << mGlyphs[i].index << "_advance_x;" << endl;
        output << "    pGlyph.bezier_n_writes   = " << fontname << "_glyph_" << mGlyphs[i].index << "_size;" << endl;
        output << "    pGlyph.bezier            = " << fontname << "_glyph_" << mGlyphs[i].index << ";" << endl;
        output << "    pGlyph.triangle_n_writes = " << fontname << "_glyph_" << mGlyphs[i].index << "_triangle_size;" << endl;
        output << "    pGlyph.triangle          = " << fontname << "_glyph_" << mGlyphs[i].index << "_triangles;" << endl;
        output << "    " << fontname << "_glyphlist[" << i << "] = pGlyph;" << endl;
    }

    output << " }" << endl << endl;

    output << "orgfx_vector_font init_" << fontname << "()" << endl;
    output << "{" << endl;
    output << "    orgfx_vector_font font = orgfx_make_vector_font(" << fontname << "_glyphlist," << endl;
    output << "                                                    " << fontname << "_nGlyphs," << endl;
    output << "                                                    " << fontname << "_glyphindexlist," << endl;
    output << "                                                    256);" << endl;
    output << "    generate_" << fontname << "();" << endl;
    output << "    orgfx_init_vector_font(font);" << endl;
    output << "    return font;" << endl;
    output << "}" << endl << endl;

    output << "#endif" << endl;
    output.close();
}

vector<Point*>       TTFPoint::GetShapePoints(int i, vector< vector<BPoint> > &shapes)
{
    vector<Point*> polyline;
    vector<BPoint> &shape = shapes[i];
    for(unsigned int j = 0; j < shape.size(); j++)
        polyline.push_back(new Point(shape[j].x, shape[j].y));
    return polyline;
}

deque<TriangleWrite> TTFPoint::Triangulate(deque<BPoint> &untangledPointList)
{
    vector<BPoint> polyline;
    vector< vector<BPoint> > shapes;
    deque<TriangleWrite> triangle_writes;

    // add all points to polyline
    bool empty = true;
    for(unsigned int i=0; i< untangledPointList.size(); i++)
    {
        if(untangledPointList[i].internalControlPoint == 1 || untangledPointList[i].onLine)
        {
            polyline.push_back(BPoint(untangledPointList[i].x, untangledPointList[i].y));
            empty = false;
        }
        if(untangledPointList[i].endOfContour == 1 && i > 0)
        {
            shapes.push_back(polyline);
            polyline.clear();
            empty = true;
        }
    }
    if(empty == false)
    {
        shapes.push_back(polyline);
    }

    if(!shapes.size())
        return triangle_writes;

    CDT*  cdt = new CDT(GetShapePoints(0, shapes));
    cdt->Triangulate();
    int beginningOfShape = 0;

    cout << "Triangulating " << shapes.size() << " contours..." << endl;

    for(unsigned int i=1; i<shapes.size(); i++)
    {
        vector<Triangle*> triangles = cdt->GetTriangles();
        cout << "Triangles: " << triangles.size() << endl;

        // Pick the first point in the shape
        BPoint firstPoint = shapes[i][0];
        float x = firstPoint.x;
        float y = firstPoint.y;

        bool isHole = false;

        // Check this point against all triangles
        for(unsigned int j=0; j<triangles.size(); j++)
        {
            //poly2tri point
            Point *p0 = triangles[j]->GetPoint(0);
            Point *p1 = triangles[j]->PointCCW(*p0); // get clockwise next point after point
            Point *p2 = triangles[j]->PointCCW(*p1); // get clockwise next point after point

            // Calculate edges
            float e0 = -(p2->y-p1->y)*(x-p1->x)+(p2->x-p1->x)*(y-p1->y);
            float e1 = -(p0->y-p2->y)*(x-p2->x)+(p0->x-p2->x)*(y-p2->y);
            float e2 = -(p1->y-p0->y)*(x-p0->x)+(p1->x-p0->x)*(y-p0->y);

            // If the point is inside the triangle, this must be a hole

            if(e0 >= 0 && e1 >= 0 && e2 >= 0)
            {
                isHole = true;
                break;
            }
        }

        // If this is a hole, we need to add it and start over
        if(isHole)
        {
            cout << "Found hole!" << endl;
            delete cdt;
            cdt = new CDT(GetShapePoints(beginningOfShape, shapes));
            for(unsigned int j = beginningOfShape + 1; j <= i; j++)
                cdt->AddHole(GetShapePoints(j, shapes));
            cdt->Triangulate();
        }
        // If this isn't a hole, it is a new shape
        // Print the old one to writes, then create a new one
        else
        {
            cout << "Writing shape with " << triangles.size() << " triangles!" << endl;

            for(unsigned int j=0; j<triangles.size(); j++)
            {
                //poly2tri point
                Point *p0 = triangles[j]->GetPoint(0);
                Point *p1 = triangles[j]->PointCCW(*p0); // get clockwise next point after point
                Point *p2 = triangles[j]->PointCCW(*p1); // get clockwise next point after point

                triangle_writes.push_back(TriangleWrite(BPoint(p0->x, p0->y),
                                                        BPoint(p1->x, p1->y),
                                                        BPoint(p2->x, p2->y)));
            }

            delete cdt;
            cdt = new CDT(GetShapePoints(i, shapes));
            cdt->Triangulate();
            beginningOfShape = i;
        }

    }


    vector<Triangle*> triangles = cdt->GetTriangles();
    cout << "Writing shape with " << triangles.size() << " triangles!" << endl;

    // Write the final shape
    for(unsigned int j=0; j<triangles.size(); j++)
    {
        //poly2tri point
        Point *p0 = triangles[j]->GetPoint(0);
        Point *p1 = triangles[j]->PointCCW(*p0); // get clockwise next point after point
        Point *p2 = triangles[j]->PointCCW(*p1); // get clockwise next point after point

        triangle_writes.push_back(TriangleWrite(BPoint(p0->x, p0->y),
                                                BPoint(p1->x, p1->y),
                                                BPoint(p2->x, p2->y)));
    }



    /*

    for(unsigned int i=1; i<shapes.size(); i++)
    {
        cdt->AddHole(shapes[i]);
    }

    cdt->Triangulate();
    triangles = cdt->GetTriangles();
    cout << "Triangles: " << triangles.size() << endl;

    for(unsigned int i=0; i<triangles.size(); i++)
    {
        //poly2tri point
        Point *p0 = triangles[i]->GetPoint(0);
        Point *p1 = triangles[i]->PointCCW(*p0); // get clockwise next point after point
        Point *p2 = triangles[i]->PointCCW(*p1); // get clockwise next point after point

        triangle_writes.push_back(TriangleWrite(BPoint(p0->x, p0->y),
                                                BPoint(p1->x, p1->y),
                                                BPoint(p2->x, p2->y)));
    }

    */

    delete cdt;
    return triangle_writes;
}
