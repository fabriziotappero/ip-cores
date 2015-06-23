#include "orgfx_plus.h"
#include "orgfx_3d.h"
#include <math.h>

int main(void)
{
	int i;

	// Initialize screen, no double buffering
    int screen = orgfxplus_init(640, 480, 16, 1);

	/*
		    a
		   b c
		  d e f
	  */

    orgfx_point a = {0, -75, 100};
    orgfx_point b = {-50, -25, 0};
    orgfx_point c = {50, -25, 0};
    orgfx_point d = {-100, 25, 100};
    orgfx_point e = {0, 25, 0};
    orgfx_point f = {100, 25, 100};

	float rad = 0;
	int t = 0;

    orgfx_point offset = {350, 300, 0};

	while(1)
	{
        orgfx_point scale = {1.0, 1.0, 1.0}; // + sin(t / 1000.f);

		// Clear screen
        orgfxplus_fill(0,0,640,480,0xffff);
		for(i = 0; i < 2000000; ++i);

        orgfx_point a_ = orgfx3d_translate(orgfx3d_scale(orgfx3d_rotateY(a, rad), scale), offset);
        orgfx_point b_ = orgfx3d_translate(orgfx3d_scale(orgfx3d_rotateY(b, rad), scale), offset);
        orgfx_point c_ = orgfx3d_translate(orgfx3d_scale(orgfx3d_rotateY(c, rad), scale), offset);
        orgfx_point d_ = orgfx3d_translate(orgfx3d_scale(orgfx3d_rotateY(d, rad), scale), offset);
        orgfx_point e_ = orgfx3d_translate(orgfx3d_scale(orgfx3d_rotateY(e, rad), scale), offset);
        orgfx_point f_ = orgfx3d_translate(orgfx3d_scale(orgfx3d_rotateY(f, rad), scale), offset);

        orgfx_triangle(a_, c_, b_, 0xf800, 1);
		for(i = 0; i < 100000; ++i);

        orgfx_triangle(b_, e_, d_, 0xf800, 1);
		for(i = 0; i < 100000; ++i);

        orgfx_triangle(c_, f_, e_, 0xf800, 1);
		for(i = 0; i < 100000; ++i);

		t += 1;
		rad += 0.1;
		if(rad >= M_PI*2) rad -= M_PI*2;

		// Swap buffers
        orgfxplus_flip();
	}
}
