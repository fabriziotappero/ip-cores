/* Mesh definition */

#ifndef cube_H
#define cube_H
#include "orgfx_3d.h"

// Call this function to get an initialized mesh:
orgfx_mesh init_cube_mesh();

unsigned int cube_nverts = 8;

unsigned int cube_nuvs   = 0;

unsigned int cube_nfaces = 12;

orgfx_point3 cube_verts[] = {
{0, 0, 0},
{0, 0, 1},
{0, 1, 0},
{0, 1, 1},
{1, 0, 0},
{1, 0, 1},
{1, 1, 0},
{1, 1, 1},
};

orgfx_point2 cube_uvs[] = {
};

orgfx_face cube_faces[] = {
{0u, 6u, 4u, 26831u},
{0u, 2u, 6u, 52671u},
{0u, 3u, 2u, 16001u},
{0u, 1u, 3u, 898u},
{2u, 7u, 6u, 63251u},
{2u, 3u, 7u, 11416u},
{4u, 6u, 7u, 934u},
{4u, 7u, 5u, 11472u},
{0u, 4u, 5u, 52695u},
{0u, 5u, 1u, 28786u},
{1u, 5u, 7u, 56277u},
{1u, 7u, 3u, 21003u},
};

orgfx_mesh init_cube_mesh()
{
  return orgfx3d_make_mesh(cube_faces,
                           cube_nfaces,
                           cube_verts,
                           cube_nverts,
                           cube_uvs,
                           cube_nuvs);
}

#endif // cube_H
