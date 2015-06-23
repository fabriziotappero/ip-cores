/*
Bare metal OpenCores GFX IP driver for Wishbone bus.

Anton Fosselius, Per Lenander 2012
  */

#include "orgfx_tileset.h"
#include "orgfx_plus.h"
#include "orgfx.h"

orgfx_tileset orgfx_make_tileset(int surface, orgfx_sprite_rect* rects, int numrects)
{
    orgfx_tileset tileset;
    tileset.surface = surface;
    tileset.rects = rects;
    tileset.numrects = numrects;
    return tileset;
}

void orgfx_draw_tile(unsigned int x0, unsigned int y0, orgfx_tileset* tileset, int sprite)
{
    if(sprite >= tileset->numrects) return;

    orgfx_sprite_rect rect = tileset->rects[sprite];
    orgfxplus_draw_surface_section(x0, y0,
                                    rect.x0, rect.y0, rect.x1, rect.y1,
                                    tileset->surface);
}

