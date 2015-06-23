#include "orgfx_plus.h"
#include "orgfx_3d.h"
#include "orgfx.h"
#include "orgfx_bitmap_font.h"
#include <math.h>

#include "cube.obj.h"
#include "humanoid_tri.obj.h"
#include "Bahamut_cc.png.h"

#include "franklin_font.h"

// State defines
enum
{
    STATE_ORSOC_SPLASH = 0,
    STATE_GEOMETRY,
    STATE_FILLMODES,
    STATE_COLORKEY,
    STATE_3D,

    LAST_STATE
};

// Color defines
#define C_RED 0xf800
#define C_WHITE 0xffff
#define C_BLACK 0x0000
#define C_BLUE 0x003f
#define C_GREEN 0x07c0

int main(void)
{
    // Initialize screen, with double buffering
    int screen = orgfxplus_init(640, 480, 16, 1, 1);

    orgfx_enable_cliprect(1);

    // Initialize bahamut_sprite
    int bahamut_sprite = init_Bahamut_cc_sprite();

    // Initialize franklin_font
    orgfx_bitmap_font franklin_font = init_franklin_font(2, 16);

    // Initialize mesh
    orgfx_mesh mesh = init_humanoid_tri_mesh();

    int state = STATE_ORSOC_SPLASH;
//    int state = STATE_3D;
    int stateTimer = 0;
    const int stateTimerMax = 20;
    int i;

    orgfxplus_fill(0,0,640*FIXEDW,480*FIXEDW,C_WHITE);
    orgfxplus_flip();

    float rad = 0;

    while(1)
    {
        // Clear screen
        orgfxplus_fill(0,0,640*FIXEDW,480*FIXEDW,C_WHITE);
        for(i = 0; i < 1500000; ++i);

        orgfxplus_colorkey(0xf81f, 1);

        // State specific logic
        switch(state)
        {
        case STATE_ORSOC_SPLASH:
        {
            // Add a logo

            orgfx_put_bitmap_text(&franklin_font, 50*FIXEDW, 300*FIXEDW,
                            L"ORSOC Graphics Accelerator Demo");
        for(i = 0; i < 500000; ++i);

            orgfx_put_bitmap_text(&franklin_font, 50*FIXEDW, 340*FIXEDW,
                            L"Per Lenander & Anton Fosselius, 2012");
            break;
        }
        case STATE_GEOMETRY:
        {
            orgfxplus_fill(50*FIXEDW, 50*FIXEDW,
                            150*FIXEDW, 150*FIXEDW,
                            C_RED);

            orgfxplus_line(-350*FIXEDW,50*FIXEDW,
                            450*FIXEDW,100*FIXEDW,
                            C_RED);
            orgfxplus_line(400*FIXEDW,50*FIXEDW,
                            450*FIXEDW,150*FIXEDW,
                            C_GREEN);
            orgfxplus_line(450*FIXEDW,100*FIXEDW,
                            350*FIXEDW,150*FIXEDW,
                            C_BLUE);

            orgfxplus_triangle(100*FIXEDW,-250*FIXEDW,
                                200*FIXEDW,250*FIXEDW,
                                150*FIXEDW,350*FIXEDW,
                                C_RED);

            orgfxplus_colorkey(0xf81f, 0);
            orgfxplus_draw_surface(300*FIXEDW, 200*FIXEDW,
                                    bahamut_sprite);

            break;
        }
        case STATE_FILLMODES:
        {
            orgfx_point3 offset = {200, 200, 0};
            orgfx_point3 rotation = {0,0,rad};

            orgfx_enable_transform(1);

            orgfx_matrix m = orgfx3d_identity();
            m = orgfx3d_rotateX(m, rotation.x);
            m = orgfx3d_rotateY(m, rotation.y);
            m = orgfx3d_rotateZ(m, rotation.z);
            m = orgfx3d_translate(m, offset);
            orgfx3d_set_matrix(m);

            orgfx_set_colors(C_RED, C_GREEN, C_BLUE);

            // Flat color (Red)
            orgfx_triangle(-50*FIXEDW, -50*FIXEDW,
                            50*FIXEDW, -50*FIXEDW,
                            0*FIXEDW, 50*FIXEDW,
                            0);

            offset.x = 50;

            m = orgfx3d_identity();
            m = orgfx3d_rotateX(m, rotation.x);
            m = orgfx3d_rotateY(m, rotation.y);
            m = orgfx3d_rotateZ(m, rotation.z);
            m = orgfx3d_translate(m, offset);
            orgfx3d_set_matrix(m);

            // Interpolated color RGB
            orgfxplus_alpha(0x00ffffff, 1);

            orgfx_triangle(-50*FIXEDW, -50*FIXEDW,
                            50*FIXEDW, -50*FIXEDW,
                            0*FIXEDW, 50*FIXEDW,
                            1);
            orgfxplus_alpha(GFX_OPAQUE, 0);

            offset.x = 300;
            offset.y = 300;

            m = orgfx3d_identity();
            m = orgfx3d_rotateX(m, rotation.x);
            m = orgfx3d_rotateY(m, rotation.y);
            m = orgfx3d_rotateZ(m, rotation.z);
            m = orgfx3d_translate(m, offset);
            orgfx3d_set_matrix(m);

            orgfx_enable_tex0(1);
            orgfxplus_bind_tex0(bahamut_sprite);

            // Textured triangle
            orgfx_uv(0,0,186,0,0,248);
            orgfx_triangle(-98*FIXEDW, -124*FIXEDW,
                            98*FIXEDW, -124*FIXEDW,
                            -98*FIXEDW, 124*FIXEDW,
                            1);

            orgfx_uv(186,0,186,248,0,248);
            orgfx_triangle(98*FIXEDW, -124*FIXEDW,
                            98*FIXEDW, 124*FIXEDW,
                            -98*FIXEDW, 124*FIXEDW,
                            1);

            orgfx_enable_tex0(0);

            orgfx_enable_transform(0);

            break;
        }
        case STATE_COLORKEY:
        {

            orgfxplus_colorkey(0xf81f, 0);
            orgfxplus_draw_surface(-50*FIXEDW, -50*FIXEDW,
                                    bahamut_sprite);

            orgfxplus_colorkey(0xf81f, 1);
            orgfxplus_draw_surface(250*FIXEDW, 50*FIXEDW,
                                    bahamut_sprite);

            orgfxplus_alpha(0xffffff00 | (unsigned int)((1+sin(2*rad))/2.0*0xff), 1);
            orgfxplus_draw_surface(150*FIXEDW, 250*FIXEDW,
                                    bahamut_sprite);
            orgfxplus_alpha(GFX_OPAQUE, 0);
            break;
        }
        case STATE_3D:
        {
            orgfx_point3 translation = {200, 500, 0};
            orgfx_point3 rotation = {-1.5,0,rad};
            orgfx_point3 scale = {25.0, 25.0, 25.0};

            orgfx3d_draw_mesh(&mesh, translation, rotation, scale, 0, 0);

            orgfx_clear_zbuffer();
            for(i = 0; i < 1500000; ++i);

            orgfx_enable_zbuffer(1);

            translation.x += 300;
            rotation.z = -rad;

            orgfx3d_draw_mesh(&mesh, translation, rotation, scale, 1, 0);

            orgfx_enable_zbuffer(0);
            break;
        }
        }

        // Increment state
        stateTimer++;
        if(stateTimer >= stateTimerMax)
        {
            stateTimer = 0;
            state++;
            if(state >= LAST_STATE)
                state = STATE_ORSOC_SPLASH;
        }

        rad += 0.05;
        if(rad >= M_PI*2) rad -= M_PI*2;

        for(i = 0; i < 500000; ++i);
        // Swap buffers
        orgfxplus_flip();
    }
}


