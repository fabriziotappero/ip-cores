/*
Bare metal OpenCores GFX IP driver for Wishbone bus.

Anton Fosselius, Per Lenander 2012
  */

#ifndef ORGFX_TILESET_H
#define ORGFX_TILESET_H

typedef struct orgfx_sprite_rect
{
    unsigned int x0, y0, x1, y1;
} orgfx_sprite_rect;

typedef struct orgfx_tileset
{
    int surface;
    struct orgfx_sprite_rect* rects;
    int numrects;
} orgfx_tileset;

orgfx_tileset orgfx_make_tileset(int surface, orgfx_sprite_rect* rects, int numrects);

void orgfx_draw_tile(unsigned int x0, unsigned int y0, orgfx_tileset* tileset, int sprite);

#endif // orgfx_TILESET_H
