/*
Bare metal OpenCores GFX IP driver for Wishbone bus.

Anton Fosselius, Per Lenander 2012
  */

#ifndef ORGFX_3D_H
#define ORGFX_3D_H

#include "orgfx.h"

typedef struct orgfx_face
{
	unsigned int p1, p2, p3;
    unsigned int uv1, uv2, uv3;
    unsigned int color1, color2, color3;
} orgfx_face;

typedef struct orgfx_matrix
{
  float aa, ab, ac, tx;
  float ba, bb, bc, ty;
  float ca, cb, cc, tz;
} orgfx_matrix;

orgfx_matrix orgfx3d_identity(void);
orgfx_matrix orgfx3d_rotateX(orgfx_matrix mat, float rad);
orgfx_matrix orgfx3d_rotateY(orgfx_matrix mat, float rad);
orgfx_matrix orgfx3d_rotateZ(orgfx_matrix mat, float rad);
orgfx_matrix orgfx3d_scale(orgfx_matrix mat, orgfx_point3 s);
orgfx_matrix orgfx3d_translate(orgfx_matrix mat, orgfx_point3 t);

inline void orgfx3d_set_matrix(orgfx_matrix mat);

typedef struct orgfx_mesh
{
    orgfx_point3 translation;
    orgfx_point3 rotation;
    orgfx_point3 scale;

	unsigned int numVerts;
    orgfx_point3 *verts;
    unsigned int numUvs;
    orgfx_point2 *uvs;
	unsigned int numFaces;
    orgfx_face *faces;
} orgfx_mesh;

orgfx_mesh orgfx3d_make_mesh(orgfx_face* faces,
                             unsigned int nFaces,
                             orgfx_point3* verts,
                             unsigned int nVerts,
                             orgfx_point2* uvs,
                             unsigned int nUvs);

// This function converts the texture coordinates in a mesh from texture space (0..1) into
// image coordinates (0..image_size).
// Warning! This function should only be called ONCE for each mesh, as it will
// modify the base mesh.
void orgfx3d_mesh_texture_size(orgfx_mesh* mesh,
                               unsigned int width,
                               unsigned int height);

void orgfx3d_draw_mesh(orgfx_mesh* mesh,
                       int filled, int textured);

#endif // orgfx_3D_H
