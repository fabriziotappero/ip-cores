/*
Bare metal OpenCores GFX IP driver for Wishbone bus.

Anton Fosselius, Per Lenander 2012
  */

#ifndef ORGFX_H
#define ORGFX_H

// Pixel definitions, use these when setting colors
//
// Pixels are defined by R,G,B where R,G,B are the most significant Red, Green and Blue bits
// All color channels are in the range 0-255
// (Greyscale is kind of subobtimal)
#define GFX_PIXEL_8(R,G,B)  (R*0.3 + G*0.59 + B*0.11)
#define GFX_PIXEL_16(R,G,B) (((R >> 3) << 11) | ((G >> 2) << 5) | (B>>3))
#define GFX_PIXEL_24(R,G,B) ((R << 16) | (G << 8) | B)
#define GFX_PIXEL_32(A,R,G,B) ((A << 24) | (R << 16) | (G << 8) | B)

#define SUBPIXEL_WIDTH 16
#define FIXEDW (1<<SUBPIXEL_WIDTH)

// Can be used as "memoryArea" in init
#define GFX_VMEM 0x00800000
//                   800000

struct orgfx_surface
{
    unsigned int addr;
    unsigned int w;
    unsigned int h;
};

typedef struct orgfx_point2
{
    float x, y;
} orgfx_point2;

typedef struct orgfx_point3
{
    float x, y, z;
} orgfx_point3;


// Must be called before any other orgfx functions.
void orgfx_init(unsigned int memoryArea);

// Set video mode
void orgfx_vga_set_videomode(unsigned int width, unsigned int height, unsigned char bpp);

// Vga stuff for double buffering (bank switching)
inline void orgfx_vga_set_vbara(unsigned int addr);
inline void orgfx_vga_set_vbarb(unsigned int addr);
inline void orgfx_vga_bank_switch();
inline unsigned int orgfx_vga_AVMP(); // Get the active memory page

struct orgfx_surface orgfx_init_surface(unsigned int width, unsigned int height);
void orgfx_bind_rendertarget(struct orgfx_surface *surface);

// Set the clip rect. Nothing outside this area will be rendered. This is reset every time you change render target
void orgfx_enable_cliprect(unsigned int enable);
void orgfx_cliprect(unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1);

// Set source rect (applied to texturing). This is reset every time you bind a new texture or enable/disable texturing
inline void orgfx_srcrect(unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1);

// Set pixels (slooooow)
inline void orgfx_set_pixel(int x, int y, unsigned int color);

// Copies a buffer into the current render target
void orgfx_memcpy(unsigned int mem[], unsigned int size);

// Primitives
inline void orgfx_set_color(unsigned int color);
inline void orgfx_set_colors(unsigned int color0, unsigned int color1, unsigned int color2);
inline void orgfx_rect(int x0, int y0, int x1, int y1);
inline void orgfx_line(int x0, int y0, int x1, int y1);
inline void orgfx_triangle(int x0, int y0,
                            int x1, int y1,
                            int x2, int y2,
                            unsigned int interpolate);
inline void orgfx_curve(int x0, int y0,
                         int x1, int y1,
                         int x2, int y2,
                         unsigned int inside);

inline void orgfx_line3d(int x0, int y0, int z0, int x1, int y1, int z1);
inline void orgfx_triangle3d(int x0, int y0, int z0,
                              int x1, int y1, int z1,
                              int x2, int y2, int z2,
                              unsigned int interpolate);

inline void orgfx_uv(unsigned int u0, unsigned int v0,
                      unsigned int u1, unsigned int v1,
                      unsigned int u2, unsigned int v2);

void orgfx_enable_tex0(unsigned int enable);
void orgfx_bind_tex0(struct orgfx_surface* surface);
void orgfx_enable_zbuffer(unsigned int enable);
void orgfx_bind_zbuffer(struct orgfx_surface *surface);
void orgfx_clear_zbuffer();

#define GFX_OPAQUE 0xffffffff

void orgfx_enable_alpha(unsigned int enable);
void orgfx_set_alpha(unsigned int alpha);

void orgfx_enable_colorkey(unsigned int enable);
void orgfx_set_colorkey(unsigned int colorkey);

void orgfx_enable_transform(unsigned int enable);
void orgfx_set_transformation_matrix(int aa, int ab, int ac, int tx,
                                      int ba, int bb, int bc, int ty,
                                      int ca, int cb, int cc, int tz);

#endif
