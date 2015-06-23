/*
Enhanced Bare metal OpenCores GFX IP driver for Wishbone bus.

This driver provides more functionality than orgfx.h

Anton Fosselius, Per Lenander 2012
  */

#include "orgfx_plus.h"
#include "orgfx.h"

#define NUM_SURFACES 10

struct orgfx_surface textures[NUM_SURFACES];
int surfaceCounter = 0;

int activeSurface = -1;

// For double buffering
unsigned char doubleBufferingEnabled = 0;
struct orgfx_surface screen0, screen1, depthBuffer;
unsigned char activeScreen = 1;

int orgfxplus_init(unsigned int width, unsigned int height, unsigned char bpp,
                    unsigned char doubleBuffering, unsigned char zbuffer)
{
    doubleBufferingEnabled = doubleBuffering;

    orgfx_init(GFX_VMEM);
    orgfx_vga_set_videomode(width, height, bpp);

    screen0 = orgfx_init_surface(width, height);
    if(doubleBuffering)
    {
        screen1 = orgfx_init_surface(width, height);
        screen1.addr += 0x00800000;
        orgfx_vga_set_vbarb(screen1.addr);
        orgfx_bind_rendertarget(&screen1);
    }
    else
        orgfx_bind_rendertarget(&screen0);

    if(zbuffer)
    {
        depthBuffer = orgfx_init_surface(width, height);
        orgfx_bind_zbuffer(&depthBuffer);
    }

    return -1; // This index is used for binding the screen surface(s)
}

int orgfxplus_init_surface(unsigned int width, unsigned int height, unsigned int mem[])
{
    if(surfaceCounter >= NUM_SURFACES)
        return -1;
    textures[surfaceCounter] = orgfx_init_surface(width, height);

    int tmp = activeSurface;

    orgfxplus_bind_rendertarget(surfaceCounter);
    orgfx_memcpy(mem, width*height/2); // TODO: Only works for 16 bits!

    orgfxplus_bind_rendertarget(tmp);

    return surfaceCounter++;
}

void orgfxplus_bind_rendertarget(int surface)
{
    if(surface == -1)
    {
        if(doubleBufferingEnabled && activeScreen == 1)
            orgfx_bind_rendertarget(&screen1);
        else
            orgfx_bind_rendertarget(&screen0);
    }
    else
        orgfx_bind_rendertarget(&textures[surface]);
}

void orgfxplus_bind_tex0(int surface)
{
    if(surface == -1)
    {

    }
    else
        orgfx_bind_tex0(&textures[surface]);
}

void orgfxplus_bind_zbuffer(int surface)
{
    if(surface == -1)
    {

    }
    else
        orgfx_bind_zbuffer(&textures[surface]);
}

void orgfxplus_clip(unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1, unsigned int enable)
{
    orgfx_enable_cliprect(enable);
    orgfx_cliprect(x0, y0, x1, y1);
}

void orgfxplus_fill(int x0, int y0, int x1, int y1, unsigned int color)
{
    orgfx_enable_tex0(0);
    orgfx_set_color(color);
    orgfx_rect(x0, y0, x1, y1);
}

void orgfxplus_line(int x0, int y0, int x1, int y1, unsigned int color)
{
    orgfx_enable_tex0(0);
    orgfx_set_color(color);
    orgfx_line(x0, y0, x1, y1);
}

void orgfxplus_triangle(int x0, int y0, int x1, int y1, int x2, int y2, unsigned int color)
{
    orgfx_enable_tex0(0);
    orgfx_set_color(color);
    orgfx_triangle(x0, y0, x1, y1, x2, y2, 0);
}

void orgfxplus_curve(int x0, int y0, int x1, int y1, int x2, int y2, unsigned int inside, unsigned int color)
{
    orgfx_enable_tex0(0);
    orgfx_set_color(color);
    orgfx_curve(x0, y0, x1, y1, x2, y2, inside);
}

void orgfxplus_draw_surface(int x0, int y0, unsigned int surface)
{
    orgfx_enable_tex0(1);
    orgfx_bind_tex0(&textures[surface]);
    orgfx_rect(x0, y0, x0+textures[surface].w*FIXEDW, y0+textures[surface].h*FIXEDW);
}

void orgfxplus_draw_surface_section(int x0, int y0, unsigned int srcx0, unsigned int srcy0, unsigned int srcx1, unsigned int srcy1, unsigned int surface)
{
    orgfx_enable_tex0(1);
    orgfx_bind_tex0(&textures[surface]);
    orgfx_srcrect(srcx0, srcy0, srcx1, srcy1);
    orgfx_rect(x0, y0, x0+(srcx1-srcx0)*FIXEDW, y0+(srcy1-srcy0)*FIXEDW);
}

// Swap active frame buffers
void orgfxplus_flip()
{
    if(!doubleBufferingEnabled)
        return;

    orgfx_vga_bank_switch();

    // Wait until VGA has switched
    while(orgfx_vga_AVMP() != activeScreen);

    activeScreen = !activeScreen;
    if(activeSurface == -1)
    {
        if(activeScreen) orgfx_bind_rendertarget(&screen1);
        else orgfx_bind_rendertarget(&screen0);
    }
}

void orgfxplus_colorkey(unsigned int colorkey, unsigned int enable)
{
    orgfx_enable_colorkey(enable);
    orgfx_set_colorkey(colorkey);
}

void orgfxplus_alpha(unsigned int alpha, unsigned int enable)
{
    orgfx_enable_alpha(enable);
    orgfx_set_alpha(alpha);
}

