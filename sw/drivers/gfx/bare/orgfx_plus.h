/*
Enhanced Bare metal OpenCores GFX IP driver for Wishbone bus.

This driver provides more functionality than orgfx.h

Anton Fosselius, Per Lenander 2012
  */

#ifndef ORGFX_PLUS_H
#define ORGFX_PLUS_H

// Initialize gfx (use this instead of the orgfx version). Return value is the screen id, use it in bind render target
int orgfxplus_init(unsigned int width, unsigned int height, unsigned char bpp, unsigned char doubleBuffering, unsigned char zbuffer);

// Loads an image into a surface
int orgfxplus_init_surface(unsigned int width, unsigned int height, unsigned int mem[]);
void orgfxplus_bind_rendertarget(int surface);
void orgfxplus_bind_tex0(int surface);

// Swap active frame buffers
void orgfxplus_flip();

// Set the clip rect. Nothing outside this area will be rendered. This is reset every time you change render target
inline void orgfxplus_clip(unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1, unsigned int enable);

// Fill an area with a color
void orgfxplus_fill(int x0, int y0, int x1, int y1, unsigned int color);

// Draw a line with a color
void orgfxplus_line(int x0, int y0, int x1, int y1, unsigned int color);

// Draw a triangle with a color
void orgfxplus_triangle(int x0, int y0, int x1, int y1, int x2, int y2, unsigned int color);

// Bezier curve
void orgfxplus_curve(int x0, int y0, int x1, int y1, int x2, int y2, unsigned int inside, unsigned int color);

// Draw a surface to the current render target
void orgfxplus_draw_surface(int x0, int y0, unsigned int surface);
// Draw a section of a surface (between scrx0,srcy0 and srcx1,srcy1) to the current render target
void orgfxplus_draw_surface_section(int x0, int y0, unsigned int srcx0, unsigned int srcy0, unsigned int srcx1, unsigned int srcy1, unsigned int surface);

// set the colorkey and enable colorkey
inline void orgfxplus_colorkey(unsigned int colorkey, unsigned int enable);

// set the alpha value
inline void orgfxplus_alpha(unsigned int alpha, unsigned int enable);

#endif

