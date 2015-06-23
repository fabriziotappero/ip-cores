/*
Bare metal OpenCores GFX IP driver for Wishbone bus.

Anton Fosselius, Per Lenander 2012
  */

#ifndef ORGFX_BITMAP_FONT_H
#define ORGFX_BITMAP_FONT_H

#include "orgfx_tileset.h"
#include <wchar.h>

typedef struct orgfx_bitmap_font
{
    orgfx_tileset *glyphs;
    unsigned int glyphSpacing;
    unsigned int spaceWidth;
} orgfx_bitmap_font;

orgfx_bitmap_font orgfx_make_bitmap_font(orgfx_tileset* glyphs,
                                         unsigned int glyphSpacing,
                                         unsigned int spaceWidth);

void orgfx_put_bitmap_text(orgfx_bitmap_font* font,
                           unsigned int x0, unsigned int y0,
                           const wchar_t *str);

#endif // orgfx_BITMAP_FONT_H
