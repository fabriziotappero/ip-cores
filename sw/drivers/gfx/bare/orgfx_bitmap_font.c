/*
Bare metal OpenCores GFX IP driver for Wishbone bus.

Anton Fosselius, Per Lenander 2012
  */

#include "orgfx_bitmap_font.h"
#include "orgfx_plus.h"
#include "orgfx.h"

orgfx_bitmap_font orgfx_make_bitmap_font(orgfx_tileset *glyphs,
                             unsigned int glyphSpacing,
                             unsigned int spaceWidth)
{
    orgfx_bitmap_font font;
    font.glyphs = glyphs;
    font.glyphSpacing = glyphSpacing;
    font.spaceWidth = spaceWidth;
    return font;
}

void orgfx_put_bitmap_text(orgfx_bitmap_font* font, unsigned int x0, unsigned int y0, const wchar_t *str)
{
    orgfx_enable_tex0(1);
    orgfxplus_bind_tex0(font->glyphs->surface);

    unsigned int fontStride = font->glyphSpacing;

    unsigned int x = x0;

    int i = 0;

    while(1)
    {
        // Get the character in the string
        wchar_t c = str[i++];
        // Break if we reach the end of the string
        if(c == 0)
            break;

        // If c is a space, handle it specially
        if(c == ' ')
        {
            x += FIXEDW * font->spaceWidth;
            continue;
        }

        // Find the width of the requested character
        unsigned int charW = font->glyphs->rects[c].x1 - font->glyphs->rects[c].x0;

        // Draw the character
        orgfx_draw_tile(x, y0, font->glyphs, c);

        // Move the x-pointer to the next character position
        x += FIXEDW * (charW + fontStride);
    }
}


