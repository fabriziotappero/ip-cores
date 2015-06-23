#include "orgfx_plus.h"
//#include "orgfx.h"

//#include "Bahamut.gif.h"
#include "Bahamut_cc.png.h"
//#include "Bahamut8.png.h"
//#include "pixtest.png.h"

int main(void)
{
	int i;
	int pos = 0;

	// Initialize screen, no double buffering
    int screen = orgfxplus_init(640, 480, 16, 1, 0);

	// Initialize sprite
    int bahamut_sprite = orgfxplus_init_surface(186, 248, Bahamut_cc);
//	int bahamut_sprite = orgfxplus_init_surface(186, 248, Bahamut);
//	int pix_sprite = orgfxplus_init_surface(4, 1, pixtest);


//	orgfxplus_fill(0,0,640,480,0x000f);

    orgfxplus_colorkey(0xf81f, 1);
    orgfxplus_fill(0,0,640,480,0xffff);
        orgfxplus_line(200,100,10,10,0xf000);
        orgfxplus_line(200,100,351,31,0x0ff0);
        orgfxplus_line(200,100,121,231,0x000f);
        orgfxplus_line(200,100,321,231,0xf00f);
    orgfxplus_alpha(64,1);
    orgfxplus_draw_surface(100, 100, bahamut_sprite);
    orgfxplus_alpha(128,1);
    orgfxplus_draw_surface(120, 102, bahamut_sprite);
    orgfxplus_alpha(255,1);
    orgfxplus_draw_surface(140, 104, bahamut_sprite);

	for(i = 0; i < 1000000; ++i);

    orgfxplus_curve(10,10,10,110,110,110,1,0xf800);

    orgfxplus_flip();

	while(1);




	while(1)
	{
		// Draw a bahamut
//		orgfxplus_draw_surface(40+pos, 50, bahamut_sprite);
//                orgfx_set_color(0xfff0);
//                orgfx_rect(40+pos,50,186+pos,248);

/*

		// Sleep
		for(i = 0; i < 1000000; ++i);

                orgfx_enable_tex0(0);

            orgfx_set_color(0xf000);
		for(i=0; i<40; i++)
		{
			for(pos = 0; pos < 100; ++pos);
                    orgfx_line(100,200,140-i,200-i);  //vertical
		}

		for(i = 0; i < 1000; ++i);

            orgfx_set_color(0x0f00);
		for(i=0; i<40; i++)
		{
                    orgfx_line(100,200,100-i,160+i);  //vertical
			for(pos = 0; pos < 100; ++pos);
		}

		for(i = 0; i < 1000; ++i);

            orgfx_set_color(0x00f0);
		for(i=0; i<40; i++)
		{
                    orgfx_line(100,200,60+i,200+i);  //vertical
			for(pos = 0; pos < 100; ++pos);
		}

		for(i = 0; i < 1000; ++i);

            orgfx_set_color(0x00ff);
		for(i=0; i<40; i++)
		{
                    orgfx_line(100,200,100+i,240-i);  //vertical
			for(pos = 0; pos < 100; ++pos);
		}

*/
		for(i = 0; i < 1000000; ++i);

//                orgfx_line(10,200,10,290);  //vertical
//                orgfx_line(10,200,100,200); // horizontal
//                orgfx_line(10,200,100,290); // 45 deg
//
//                orgfx_line(10,200,110,400); // between v and 45
//                orgfx_line(10,200,210,300); // between h and 45



		pos+=1;
		if(pos > 300) pos = 0;

		// Swap buffers
//		orgfxplus_flip();
	}
}

