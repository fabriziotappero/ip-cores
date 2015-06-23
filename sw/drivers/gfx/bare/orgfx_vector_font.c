
#include "orgfx_vector_font.h"
#include "orgfx_3d.h"
#include "orgfx.h"

#include <stdio.h>

orgfx_vector_font orgfx_make_vector_font(Glyph *glyphlist,
                                         int size,
                                         Glyph **glyphindexlist,
                                         int glyphindexlistsize)
{
    orgfx_vector_font font;
    font.size = size;
    font.glyph = glyphlist;
    font.index_list_size = glyphindexlistsize;
    font.index_list = glyphindexlist;
    return font;
}
// takes all glyphs and generate a pointer list with correct index to all glyphs.
int orgfx_init_vector_font(orgfx_vector_font font)
{
    int i,j;
    // for all in the glyphindex.

    for(i=0; i<font.index_list_size; i++)
        font.index_list[i] = 0;

    for(i=0; i<font.size; i++)
    {
        // if character code is outside our glyph scope, return error
        if(font.glyph[i].index >= font.index_list_size)
            return 1;

        // match the glyph index with the ascii code i
        for(j=0; j<font.index_list_size; j++)
            if(j == font.glyph[i].index )
            {
                font.index_list[j] = &(font.glyph[i]);
                break;
            }
    }
    // all went well
    return 0;
}

void orgfx_put_vector_text(orgfx_vector_font* font,
                           orgfx_point3 offset,
                           orgfx_point3 scale,
                           orgfx_point3 rotation,
                           const wchar_t *str,
                           unsigned int color)
{
    int advance = 0;
    size_t cIndex = 0;

    orgfx_enable_tex0(0);
    orgfx_set_colors(color,color,color);
    orgfx_enable_transform(1);

    while(1)
    {
        wchar_t c = str[cIndex++];
        // Break if we reach the end of the string
        if(c == 0)
            break;

        // Set the transformation matrix
        orgfx_point3 glyph_offset = {advance,0,0};
        orgfx_matrix m = orgfx3d_identity();

        m = orgfx3d_rotateX(m, -2*rotation.x);
        m = orgfx3d_rotateY(m, -2*rotation.y);
        m = orgfx3d_rotateZ(m, -2*rotation.z);
        m = orgfx3d_translate(m, glyph_offset);
        m = orgfx3d_rotateX(m, rotation.x);
        m = orgfx3d_rotateY(m, rotation.y);
        m = orgfx3d_rotateZ(m, rotation.z);
        m = orgfx3d_scale(m, scale);
        m = orgfx3d_translate(m, offset);
        orgfx3d_set_matrix(m);

        if(c != ' ')
            orgfx_put_vector_char(font, c);
        else
            advance += 400;

        if(font->index_list[c])
            advance += font->index_list[c]->advance_x;
    }
    orgfx_enable_transform(0);
}

void orgfx_put_vector_char(orgfx_vector_font* font, wchar_t text)
{
    Glyph* glyph = font->index_list[text];
    if(glyph == 0)
        return;
    int i;

    for(i=0; i<glyph->triangle_n_writes; i++)
    {
        orgfx_triangle((glyph->triangle[i].p0.x)*FIXEDW,(glyph->triangle[i].p0.y)*FIXEDW,
                       (glyph->triangle[i].p1.x)*FIXEDW,(glyph->triangle[i].p1.y)*FIXEDW,
                       (glyph->triangle[i].p2.x)*FIXEDW,(glyph->triangle[i].p2.y)*FIXEDW,
                        1);
    }
    for(i=0; i<glyph->bezier_n_writes; i++)
    {
        orgfx_curve((glyph->bezier[i].start.x)  *FIXEDW, (glyph->bezier[i].start.y)  *FIXEDW,
                    (glyph->bezier[i].control.x)*FIXEDW, (glyph->bezier[i].control.y)*FIXEDW,
                    (glyph->bezier[i].end.x)    *FIXEDW, (glyph->bezier[i].end.y)    *FIXEDW,
                     glyph->bezier[i].fillInside);
    }
}
