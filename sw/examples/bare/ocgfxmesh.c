#include "orgfx_plus.h"
#include "orgfx_3d.h"
#include "orgfx.h"
#include <math.h>

#include "man.obj.h"
#include "uv.png.h"

//#include "stdio.h"

int main(void)
{
    // Initialize screen, no double buffering
    int screen = orgfxplus_init(640, 480, 16, 1, 1);

    // Set up texture and mesh
    int uv_sprite = init_uv_sprite();
    orgfx_mesh man_mesh = init_man_mesh();
    orgfx3d_mesh_texture_size(&man_mesh, 128, 128);

    // Bind the texture
    orgfxplus_bind_tex0(uv_sprite);

    float rad = 0;
    int i;

    while(1)
    {
        orgfx_point3 translation = {200, 300, 0};
        orgfx_point3 rotation = {M_PI,rad,0};
        orgfx_point3 scale = {100.0, 100.0, 100.0};

        // Clear screen
        orgfxplus_fill(0,0,640*FIXEDW,480*FIXEDW,0xffff);

        for(i = 0; i < 5000000; ++i);

        // Clear the depth buffer
        orgfx_clear_zbuffer();
        orgfx_enable_zbuffer(1);

        // Draw wireframe
        orgfx3d_draw_mesh(&man_mesh, translation, rotation, scale, 0, 0);
        translation.x += 150;

        // Draw filled
        orgfx3d_draw_mesh(&man_mesh, translation, rotation, scale, 1, 0);
        translation.x += 150;

        // Draw textured
        orgfx3d_draw_mesh(&man_mesh, translation, rotation, scale, 1, 1);
        orgfx_enable_zbuffer(0);

        // Rotate meshes
        rad += 0.01;
        if(rad >= M_PI*2) rad -= M_PI*2;

        // Swap buffers
        orgfxplus_flip();
    }
}

