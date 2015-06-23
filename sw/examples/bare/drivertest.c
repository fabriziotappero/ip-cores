#include "orgfx.h"
#include "orgfx_debug.h"

#include "Bahamut.gif.h"

#define REG32(add) *((volatile unsigned int*)(add))

int main(void)
{
    orgfx_init(GFX_VMEM);
    orgfx_vga_set_videomode(640, 480, 16);
    struct orgfx_surface screen = orgfx_init_surface(640, 480);
    orgfx_bind_rendertarget(&screen);

//	orgfx_enable_colorkey(1);
    orgfx_cliprect(0,0,640,480);

    orgfx_set_color(0xf800);
    orgfx_rect(110 <<16, 110<<16, 115<<16, 115<<16);

	while(1);



/*
	// Initialize start of video memory
    orgfx_init(GFX_VMEM);
	// Initialize color depth and vga module
	oc_vga_set_videomode(640, 480, 16);

	// Initialize screen (additional framebuffers should follow after)
    struct orgfx_surface screen = orgfx_init_surface(640, 480);

	// Bind the screen as render target
    orgfx_bind_rendertarget(&screen);

	// Initialize texture
    struct orgfx_surface bahamut = orgfx_init_surface(186, 248);
    orgfx_bind_rendertarget(&bahamut);

    orgfx_memcpy(Bahamut, 186*248/2);

	// Bind the screen as render target
    orgfx_bind_rendertarget(&screen);

//	orgfx_cliprect(50, 125, 500, 300);
    orgfx_set_color(0);
    orgfx_rect(0, 0, 640, 480);

	int i;
	for(i = 0; i < 1000000; ++i);

	// Bind bahamut as texture
    orgfx_enable_tex0(1);
    orgfx_bind_tex0(&bahamut);
//	orgfx_srcrect(50,50,100,100);

	// Draw a bahamut
    orgfx_rect(20<<16, 100<<16, 206<<16, 348<<16);

    orgfx_rect(400<<16, 100<<16, 586<<16, 348<<16);

	while(1);
*/
}

