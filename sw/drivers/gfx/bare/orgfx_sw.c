/*
Bare metal OpenCores GFX IP driver for Wishbone bus.

THIS IS A SOFTWARE IMPLEMENTATION USING SDL, FOR TESTING PROGRAMS AGAINST THE API

Anton Fosselius, Per Lenander 2012
  */

#include "orgfx.h"
#include "orgfx_plus.h"
#include "orgfx_3d.h"

#include <SDL/SDL.h>
#include <SDL/SDL_image.h>

#include <math.h>

typedef struct Point
{
    float x, y, z;
} Point;


SDL_Surface* screen = NULL;

#define NUM_SURFACES 10
SDL_Surface* surfaces[NUM_SURFACES];
int sCounter = 0;

SDL_Surface* target_surface = NULL;
SDL_Surface* tex0_surface = NULL;
SDL_Surface* zbuffer_surface = NULL;

SDL_Rect cliprect;
SDL_Rect srcrect;

unsigned int color_depth_reg = 16;

unsigned int texture_enable = 0;
unsigned int blend_enable = 0;
unsigned int colorkey_enable = 0;
unsigned int clipping_enable = 0;
unsigned int transform_enable = 0;
unsigned int zbuffer_enable = 0;

int z_reg = 0;

unsigned int colorkey_reg = 0;
float alpha_global_reg = 1;
float alpha0_reg = 1;
float alpha1_reg = 1;
float alpha2_reg = 1;
float pixel_alpha = 1;

unsigned int u0_reg = 0, v0_reg = 0;
unsigned int u1_reg = 0, v1_reg = 0;
unsigned int u2_reg = 0, v2_reg = 0;

float aa_reg = 1;
float ab_reg = 0;
float ac_reg = 0;
float tx_reg = 0;
float ba_reg = 0;
float bb_reg = 1;
float bc_reg = 0;
float ty_reg = 0;
float ca_reg = 0;
float cb_reg = 0;
float cc_reg = 1;
float tz_reg = 0;

// Pixel manipulation
void put_pixel16( SDL_Surface *surface, int x, int y, Uint16 pixel )
{
    if(x<0 || x > surface->w)
        return;
    if(y<0 || y > surface->h)
        return;
    //Convert the pixels to 16 bit
    Uint16 *pixels = (Uint16 *)surface->pixels;

    //Set the pixel
    pixels[ ( y * surface->w ) + x ] = pixel;
}

Uint16 get_pixel16( SDL_Surface *surface, int x, int y )
{
    if(x<0 || x > surface->w)
        return;
    if(y<0 || y > surface->h)
        return;
    //Convert the pixels to 16 bit
    Uint16 *pixels = (Uint16 *)surface->pixels;

    //Get the requested pixel
    return pixels[ ( y * surface->w ) + x ];
}


unsigned int color0_reg = 0, color1_reg = 0, color2_reg = 0;

unsigned int gfx_control_reg_memory = 0;

Point toPoint(int x, int y, int z)
{
    Point p;
    p.x = (float)x / FIXEDW;
    p.y = (float)y / FIXEDW;
    p.z = (float)z / FIXEDW;

    //printf("x: %d y: %d z: %d  --->  ", x, y, z);
    //printf("p: %f,%f,%f\n", p.x, p.y, p.z);

    if(!transform_enable)
        return p;

    Point ret;

    ret.x = aa_reg*p.x + ab_reg*p.y + ac_reg*p.z + tx_reg;
    ret.y = ba_reg*p.x + bb_reg*p.y + bc_reg*p.z + ty_reg;
    ret.z = ca_reg*p.x + cb_reg*p.y + cc_reg*p.z + tz_reg;

    return ret;
}

void orgfx_init(unsigned int memoryArea)
{
    SDL_Init(SDL_INIT_VIDEO);
}

void orgfx_vga_set_vbara(unsigned int addr)
{

}

void orgfx_vga_set_vbarb(unsigned int addr)
{

}

inline void orgfx_vga_bank_switch()
{

}

void orgfx_vga_set_videomode(unsigned int width, unsigned int height, unsigned char bpp)
{
    color_depth_reg = bpp;
    screen = SDL_SetVideoMode(width, height, bpp, SDL_DOUBLEBUF);
    target_surface = screen;
}

struct orgfx_surface orgfx_init_surface(unsigned int width, unsigned int height)
{
    static int screenInitialized = 0;
    struct orgfx_surface surface;

    surface.addr = sCounter;

    if(screenInitialized)
    {
        SDL_Surface* s = SDL_CreateRGBSurface(0,width, height, color_depth_reg, 0, 0, 0, 0);
        surfaces[sCounter] = s;
        surface.w = s->w;
        surface.h = s->h;
    }
    else
    {
        surfaces[sCounter] = screen;
        surface.w = screen->w;
        surface.h = screen->h;
        screenInitialized = 1;
    }

    sCounter++;

    return surface;
}

void orgfx_bind_rendertarget(struct orgfx_surface *surface)
{
    unsigned int sIndex = surface->addr;
    target_surface = surfaces[sIndex];
    // Clear clip rect
    orgfx_cliprect(0,0,surface->w,surface->h);
}

void orgfx_enable_cliprect(unsigned int enable)
{
    clipping_enable = enable;
}

void orgfx_cliprect(unsigned int x0, unsigned int y0,
                     unsigned int x1, unsigned int y1)
{
    cliprect.x = x0;
    cliprect.y = y0;
    cliprect.w = x1-x0;
    cliprect.h = y1-y0;
}

void orgfx_srcrect(unsigned int x0, unsigned int y0,
                    unsigned int x1, unsigned int y1)
{
    srcrect.x = x0;
    srcrect.y = y0;
    srcrect.w = x1-x0;
    srcrect.h = y1-y0;
}

void orgfx_init_src()
{
    if(texture_enable && tex0_surface)
        orgfx_srcrect(0, 0, tex0_surface->w, tex0_surface->h);
    else if(target_surface)
        orgfx_srcrect(0, 0, target_surface->w, target_surface->h);
}

void orgfx_set_pixel(int x, int y, unsigned int color)
{
    if(!colorkey_enable || colorkey_reg != color)
    {
        // Check for depth
        if(zbuffer_enable)
        {
            short depthAtTarget = get_pixel16(zbuffer_surface, x, y);

            if(depthAtTarget > z_reg)
            {
                //printf("Z: %d ZBUF: %d\n", z_reg, depthAtTarget);
                return;
            }
            else
                put_pixel16(zbuffer_surface, x, y, z_reg);
        }

        if(blend_enable)
        {
            unsigned int targetCol = get_pixel16(target_surface, x, y);

            float alpha = alpha_global_reg * pixel_alpha;

            Uint8 rt = targetCol >> 11, rc = color >> 11;
            Uint8 gt = (targetCol >> 5) & 0x3f, gc = (color >> 5) & 0x3f;
            Uint8 bt = targetCol & 0x1f, bc = color & 0x1f;

            Uint8 r = alpha*rc+(1.0 - alpha)*rt;
            Uint8 g = alpha*gc+(1.0 - alpha)*gt;
            Uint8 b = alpha*bc+(1.0 - alpha)*bt;

            color = (r << 11) + (g << 5) + b;
        }
        put_pixel16(target_surface, x, y, color);
    }
}

// Copies a buffer into the current render target
void orgfx_memcpy(unsigned int mem[], unsigned int size)
{
    unsigned int i;
    for(i=0; i < size; ++i)
    {
        put_pixel16(target_surface,
                    (2*i)%target_surface->w,    // x
                    (2*i)/target_surface->w,    // y
                    mem[i]>>SUBPIXEL_WIDTH);    // high word
        put_pixel16(target_surface,
                    (2*i)%target_surface->w+1,  // x+1
                    (2*i)/target_surface->w,    // y
                    mem[i]&0xffff);             // low word
    }
}

void orgfx_clear_zbuffer()
{
    if(zbuffer_surface)
        SDL_FillRect(zbuffer_surface, NULL, -32768); // -maxdepth
}

void orgfx_set_color(unsigned int color)
{
    color0_reg = color;
}


void orgfx_set_colors(unsigned int color0, unsigned int color1, unsigned int color2)
{
    color0_reg = color0;
    color1_reg = color1;
    color2_reg = color2;
}

void orgfx_rect(int x0, int y0,
                 int x1, int y1)
{
    Point p0 = toPoint(x0, y0, 0);
    Point p1 = toPoint(x1, y1, 0);
    pixel_alpha = 1;

    SDL_Rect dest;
    dest.x = p0.x;
    dest.y = p0.y;
    dest.w = p1.x-p0.x;
    dest.h = p1.y-p0.y;

    if(texture_enable)
    {
        int y, x, u, v;
        for(y = p0.y, v = srcrect.y; y < p1.y; ++y, ++v)
            for(x = p0.x, u = srcrect.x; x < p1.x; ++x, ++u)
                orgfx_set_pixel(x, y, get_pixel16(tex0_surface, u, v));
    }
    //   SDL_BlitSurface(tex0_surface, &srcrect, target_surface, &dest);
    else
    {
        int y, x;
        for(y = p0.y; y < p1.y; ++y)
            for(x = p0.x; x < p1.x; ++x)
                orgfx_set_pixel(x, y, color0_reg);
    }
    //   SDL_FillRect(target_surface, &dest, color0_reg);
}

void orgfx_line(int x0, int y0,
                 int x1, int y1)
{
    orgfx_line3d(x0, y0, 0, x1, y1, 0);
}


void orgfx_line3d(int x0, int y0, int z0,
                   int x1, int y1, int z1)
{
    Point p0 = toPoint(x0, y0, z0);
    Point p1 = toPoint(x1, y1, z1);
    pixel_alpha = 1;

    orgfx_set_pixel(p0.x,p0.y,color0_reg);
    orgfx_set_pixel(p1.x,p1.y,color0_reg);

    int X0 = p0.x, Y0 = p0.y;
    int X1 = p1.x, Y1 = p1.y;
    int dx = abs(X1-X0), sx = X0<X1 ? 1 : -1;
    int dy = abs(Y1-Y0), sy = Y0<Y1 ? 1 : -1;
    int err = (dx>dy ? dx : -dy)/2, e2;

    for(;;){
        orgfx_set_pixel(X0, Y0, color0_reg);
        if (X0==X1 && Y0==Y1) break;
        e2 = err;
        if (e2 >-dx) { err -= dy; X0 += sx; }
        if (e2 < dy) { err += dx; Y0 += sy; }
    }
}

void orgfx_triangle(int x0, int y0,
                     int x1, int y1,
                     int x2, int y2,
                     unsigned int interpolate)
{
    orgfx_triangle3d(x0, y0, 0, x1, y1, 0, x2, y2, 0, interpolate);
}

void orgfx_curve(int x0, int y0,
                  int x1, int y1,
                  int x2, int y2,
                  unsigned int inside)
{
    Point p0 = toPoint(x0, y0, 0);
    Point p1 = toPoint(x1, y1, 0);
    Point p2 = toPoint(x2, y2, 0);

    float xmin = p0.x; float xmax = p0.x;
    if(p1.x < xmin) xmin = p1.x; if(p1.x > xmax) xmax = p1.x;
    if(p2.x < xmin) xmin = p2.x; if(p2.x > xmax) xmax = p2.x;
    float ymin = p0.y; float ymax = p0.y;
    if(p1.y < ymin) ymin = p1.y; if(p1.y > ymax) ymax = p1.y;
    if(p2.y < ymin) ymin = p2.y; if(p2.y > ymax) ymax = p2.y;

    float area = (p1.x - p0.x)*(p2.y-p0.y) - (p2.x-p0.x)*(p1.y-p0.y);

    float x, y;

    for(y = ymin; y < ymax; y++)
    {
        for(x = xmin; x < xmax; x++)
        {
            float e0 = -(p2.y-p1.y)*(x-p1.x)+(p2.x-p1.x)*(y-p1.y);
            float e1 = -(p0.y-p2.y)*(x-p2.x)+(p0.x-p2.x)*(y-p2.y);
            float e2 = -(p1.y-p0.y)*(x-p0.x)+(p1.x-p0.x)*(y-p0.y);

            if(e0 >= 0 && e1 >= 0 && e2 >= 0)
            {
                float factor1 = e1/area;
                float factor2 = e2/area;
                float factor0 = 1 - factor1 - factor2;

                if(blend_enable)
                    pixel_alpha = factor0*alpha0_reg + factor1*alpha1_reg + factor2*alpha2_reg;
                else
                    pixel_alpha = 1;

                float bezierFactor0 = factor1/2.0 + factor2;
                float bezierFactor1 = factor2;

                if(inside)
                {
                    if(bezierFactor0*bezierFactor0 < bezierFactor1)
                        orgfx_set_pixel( x, y, color0_reg);
                }
                else if(bezierFactor0*bezierFactor0 > bezierFactor1)
                    orgfx_set_pixel( x, y, color0_reg);
            }
        }
    }
}

#include <stdio.h>

void orgfx_triangle3d(int x0, int y0, int z0,
                       int x1, int y1, int z1,
                       int x2, int y2, int z2,
                       unsigned int interpolate)
{
    Point p0 = toPoint(x0, y0, z0);
    Point p1 = toPoint(x1, y1, z1);
    Point p2 = toPoint(x2, y2, z2);

    float xmin = p0.x; float xmax = p0.x;
    if(p1.x < xmin) xmin = p1.x; if(p1.x > xmax) xmax = p1.x;
    if(p2.x < xmin) xmin = p2.x; if(p2.x > xmax) xmax = p2.x;
    float ymin = p0.y; float ymax = p0.y;
    if(p1.y < ymin) ymin = p1.y; if(p1.y > ymax) ymax = p1.y;
    if(p2.y < ymin) ymin = p2.y; if(p2.y > ymax) ymax = p2.y;

    float area = (p1.x - p0.x)*(p2.y-p0.y) - (p2.x-p0.x)*(p1.y-p0.y);

    if(area < 0)
        return;

    pixel_alpha = 1;

    float x, y;

    for(y = ymin; y < ymax; y++)
    {
        for(x = xmin; x < xmax; x++)
        {
            float e0 = -(p2.y-p1.y)*(x-p1.x)+(p2.x-p1.x)*(y-p1.y);
            float e1 = -(p0.y-p2.y)*(x-p2.x)+(p0.x-p2.x)*(y-p2.y);
            float e2 = -(p1.y-p0.y)*(x-p0.x)+(p1.x-p0.x)*(y-p0.y);

            if(e0 >= 0 && e1 >= 0 && e2 >= 0)
            {
                if(interpolate)
                {
                    float factor1 = e1/area;
                    float factor2 = e2/area;
                    float factor0 = 1.0 - factor1 - factor2;

                    // Calculate depth
                    z_reg = factor0*p0.z + factor1*p1.z + factor2*p2.z;

                    if(blend_enable)
                        pixel_alpha = factor0*alpha0_reg + factor1*alpha1_reg + factor2*alpha2_reg;
                    else
                        pixel_alpha = 1;

                    if(texture_enable)
                    {
                        unsigned int u = factor0*u0_reg + factor1*u1_reg + factor2*u2_reg;
                        unsigned int v = factor0*v0_reg + factor1*v1_reg + factor2*v2_reg;
                        if(u >= tex0_surface->w) u = tex0_surface->w-1;
                        if(v >= tex0_surface->h) v = tex0_surface->h-1;

                        Uint32 col = get_pixel16(tex0_surface, u, v);

                        orgfx_set_pixel(x, y, col);
                    }
                    else
                    {
                        Uint8 r0 = color0_reg >> 11, r1 = color1_reg >> 11, r2 = color2_reg >> 11;
                        Uint8 g0 = (color0_reg >> 5) & 0x3f, g1 = (color1_reg >> 5) & 0x3f, g2 = (color2_reg >> 5) & 0x3f;
                        Uint8 b0 = color0_reg & 0x1f, b1 = color1_reg & 0x1f, b2 = color2_reg & 0x1f;

                        Uint8 r = factor0*r0+factor1*r1+factor2*r2;
                        Uint8 g = factor0*g0+factor1*g1+factor2*g2;
                        Uint8 b = factor0*b0+factor1*b1+factor2*b2;

                        Uint32 col = (r << 11) + (g << 5) + b;

                        orgfx_set_pixel(x, y, col);
                    }
                }
                else
                    orgfx_set_pixel(x, y, color0_reg);
            }
        }
    }
}

void orgfx_uv(unsigned int u0, unsigned int v0,
               unsigned int u1, unsigned int v1,
               unsigned int u2, unsigned int v2)
{
    u0_reg = u0;
    v0_reg = v0;
    u1_reg = u1;
    v1_reg = v1;
    u2_reg = u2;
    v2_reg = v2;
}

void orgfx_enable_tex0(unsigned int enable)
{
    texture_enable = enable;

    orgfx_init_src();
}

void orgfx_bind_tex0(struct orgfx_surface* surface)
{
    tex0_surface = surfaces[surface->addr];

    orgfx_init_src();
}

void orgfx_enable_zbuffer(unsigned int enable)
{
    zbuffer_enable = enable;
}

void orgfx_bind_zbuffer(struct orgfx_surface *surface)
{
    unsigned int sIndex = surface->addr;
    zbuffer_surface = surfaces[sIndex];
}

void orgfx_enable_alpha(unsigned int enable)
{
    blend_enable = enable;
}

void orgfx_set_alpha(unsigned int alpha)
{
    alpha_global_reg = (float)(alpha & 0xff) / 0xff;
    alpha0_reg = (float)((alpha >> 24) & 0xff) / 0xff;
    alpha1_reg = (float)((alpha >> 16) & 0xff) / 0xff;
    alpha2_reg = (float)((alpha >> 8) & 0xff) / 0xff;
}

void orgfx_enable_colorkey(unsigned int enable)
{
    colorkey_enable = enable;
}

void orgfx_set_colorkey(unsigned int colorkey)
{
    colorkey_reg = colorkey;
}

void orgfx_enable_transform(unsigned int enable)
{
    transform_enable = enable;
}

void orgfx_set_transformation_matrix(int aa, int ab, int ac, int tx,
                                      int ba, int bb, int bc, int ty,
                                      int ca, int cb, int cc, int tz)
{
    aa_reg = (float)aa / FIXEDW;
    ab_reg = (float)ab / FIXEDW;
    ac_reg = (float)ac / FIXEDW;
    tx_reg = (float)tx / FIXEDW;
    ba_reg = (float)ba / FIXEDW;
    bb_reg = (float)bb / FIXEDW;
    bc_reg = (float)bc / FIXEDW;
    ty_reg = (float)ty / FIXEDW;
    ca_reg = (float)ca / FIXEDW;
    cb_reg = (float)cb / FIXEDW;
    cc_reg = (float)cc / FIXEDW;
    tz_reg = (float)tz / FIXEDW;
}

// ******** //
// GFX PLUS //
// ******** //

struct orgfx_surface textures[NUM_SURFACES];
int surfaceCounter = 0;

int activeSurface = -1;
struct orgfx_surface screen0;
struct orgfx_surface depthBuffer;

int orgfxplus_init(unsigned int width, unsigned int height, unsigned char bpp, unsigned char doubleBuffering, unsigned char zbuffer)
{
    orgfx_init(GFX_VMEM);
    orgfx_vga_set_videomode(width, height, bpp);

    screen0 = orgfx_init_surface(width, height);
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
        orgfx_bind_rendertarget(&screen0);
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

void orgfxplus_clip(unsigned int x0, unsigned int y0,
                     unsigned int x1, unsigned int y1,
                     unsigned int enable)
{
    orgfx_enable_cliprect(enable);
    orgfx_cliprect(x0, y0, x1, y1);
}

void orgfxplus_fill(int x0, int y0,
                     int x1, int y1,
                     unsigned int color)
{
    orgfx_enable_tex0(0);
    orgfx_set_color(color);
    orgfx_rect(x0, y0, x1, y1);
}

void orgfxplus_line(int x0, int y0,
                     int x1, int y1,
                     unsigned int color)
{
    orgfx_enable_tex0(0);
    orgfx_set_color(color);
    orgfx_line(x0, y0, x1, y1);
}

void orgfxplus_triangle(int x0, int y0,
                         int x1, int y1,
                         int x2, int y2,
                         unsigned int color)
{
    orgfx_enable_tex0(0);
    orgfx_set_color(color);
    orgfx_triangle(x0, y0, x1, y1, x2, y2, 0);
}

void orgfxplus_curve(int x0, int y0,
                      int x1, int y1,
                      int x2, int y2,
                      unsigned int inside, unsigned int color)
{
    orgfx_enable_tex0(0);
    orgfx_set_color(color);
    orgfx_curve(x0, y0, x1, y1, x2, y2, inside);
}

void orgfxplus_draw_surface(int x0, int y0,
                             unsigned int surface)
{
    orgfx_enable_tex0(1);
    orgfx_bind_tex0(&textures[surface]);
    orgfx_rect(x0, y0, x0+textures[surface].w*FIXEDW, y0+textures[surface].h*FIXEDW);
}

void orgfxplus_draw_surface_section(int x0, int y0,
                                     unsigned int srcx0, unsigned int srcy0,
                                     unsigned int srcx1, unsigned int srcy1,
                                     unsigned int surface)
{
    orgfx_enable_tex0(1);
    orgfx_bind_tex0(&textures[surface]);
    orgfx_srcrect(srcx0, srcy0, srcx1, srcy1);
    orgfx_rect(x0, y0, x0+(srcx1-srcx0)*FIXEDW, y0+(srcy1-srcy0)*FIXEDW);
}

// Swap active frame buffers
void orgfxplus_flip()
{
    SDL_Flip(screen);
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

