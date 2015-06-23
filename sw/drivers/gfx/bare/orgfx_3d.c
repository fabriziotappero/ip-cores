/*
Bare metal OpenCores GFX IP driver for Wishbone bus.

Anton Fosselius, Per Lenander 2012
  */

#include "orgfx_3d.h"
#include "orgfx.h"

#include <math.h>

orgfx_matrix orgfx3d_identity(void)
{
    orgfx_matrix i;
    i.aa = i.bb = i.cc = 1;
    i.ab = i.ac = i.ba = i.bc = i.ca = i.cb = 0;
    i.tx = i.ty = i.tz = 0;
    return i;
}

orgfx_matrix orgfx3d_rotateX(orgfx_matrix mat, float rad)
{
    orgfx_matrix ret = mat;

    float sinrad = sin(rad);
    float cosrad = cos(rad);

    //ret.aa = mat.aa
    ret.ab = mat.ab*cosrad - mat.ac*sinrad;
    ret.ac = mat.ab*sinrad + mat.ac*cosrad;
    //ret.ba = mat.ba
    ret.bb = mat.bb*cosrad - mat.bc*sinrad;
    ret.bc = mat.bb*sinrad + mat.bc*cosrad;
    //ret.ca = mat.ca
    ret.cb = mat.cb*cosrad - mat.cc*sinrad;
    ret.cc = mat.cb*sinrad + mat.cc*cosrad;
    //ret.tx = mat.tx
    ret.ty = mat.ty*cosrad - mat.tz*sinrad;
    ret.tz = mat.ty*sinrad + mat.tz*cosrad;
    return ret;
}

orgfx_matrix orgfx3d_rotateY(orgfx_matrix mat, float rad)
{
    orgfx_matrix ret = mat;

    float sinrad = sin(rad);
    float cosrad = cos(rad);

    ret.aa = mat.aa*cosrad + mat.ac*sinrad;
    //ret.ab = mat.ab
    ret.ac = -mat.aa*sinrad + mat.ac*cosrad;
    ret.ba = mat.ba*cosrad + mat.bc*sinrad;
    //ret.bb = mat.bb
    ret.bc = -mat.ba*sinrad + mat.bc*cosrad;
    ret.ca = mat.ca*cosrad + mat.cc*sinrad;
    //ret.cb = mat.cb
    ret.cc = -mat.ca*sinrad + mat.cc*cosrad;
    ret.tx = mat.tx*cosrad + mat.tz*sinrad;
    //ret.ty = mat.ty
    ret.tz = -mat.tx*sinrad + mat.tz*cosrad;
    return ret;
}

orgfx_matrix orgfx3d_rotateZ(orgfx_matrix mat, float rad)
{
    orgfx_matrix ret = mat;

    float sinrad = sin(rad);
    float cosrad = cos(rad);

    ret.aa = mat.aa*cosrad - mat.ab*sinrad;
    ret.ab = mat.aa*sinrad + mat.ab*cosrad;
    //ret.ac = mat.ac
    ret.ba = mat.ba*cosrad - mat.bb*sinrad;
    ret.bb = mat.ba*sinrad + mat.bb*cosrad;
    //ret.bc = mat.bc
    ret.ca = mat.ca*cosrad - mat.cb*sinrad;
    ret.cb = mat.ca*sinrad + mat.cb*cosrad;
    //ret.cc = mat.cc
    ret.tx = mat.tx*cosrad - mat.ty*sinrad;
    ret.ty = mat.tx*sinrad + mat.ty*cosrad;
    //ret.tz = mat.tz
    return ret;
}

orgfx_matrix orgfx3d_scale(orgfx_matrix mat, orgfx_point3 s)
{
    orgfx_matrix ret = mat;
    ret.aa *= s.x;
    ret.ab *= s.x;
    ret.ac *= s.x;
    ret.tx *= s.x;
    ret.ba *= s.y;
    ret.bb *= s.y;
    ret.bc *= s.y;
    ret.ty *= s.y;
    ret.ca *= s.z;
    ret.cb *= s.z;
    ret.cc *= s.z;
    ret.tz *= s.z;
    return ret;
}

orgfx_matrix orgfx3d_translate(orgfx_matrix mat, orgfx_point3 t)
{
    orgfx_matrix ret = mat;
    ret.tx += t.x;
    ret.ty += t.y;
    ret.tz += t.z;
    return ret;
}

void orgfx3d_set_matrix(orgfx_matrix mat)
{
    orgfx_set_transformation_matrix(mat.aa*FIXEDW, mat.ab*FIXEDW, mat.ac*FIXEDW, mat.tx*FIXEDW,
                                    mat.ba*FIXEDW, mat.bb*FIXEDW, mat.bc*FIXEDW, mat.ty*FIXEDW,
                                    mat.ca*FIXEDW, mat.cb*FIXEDW, mat.cc*FIXEDW, mat.tz*FIXEDW);
}

orgfx_mesh orgfx3d_make_mesh(orgfx_face* faces,
                             unsigned int nFaces,
                             orgfx_point3* verts,
                             unsigned int nVerts,
                             orgfx_point2* uvs,
                             unsigned int nUvs)
{
    orgfx_mesh mesh;
    mesh.numFaces = nFaces;
    mesh.numVerts = nVerts;
    mesh.numUvs = nUvs;
    mesh.translation.x = mesh.translation.y = mesh.translation.z = 0.0;
    mesh.rotation.x = mesh.rotation.y = mesh.rotation.z = 0.0;
    mesh.scale.x = mesh.scale.y = mesh.scale.z = 1.0;
    mesh.faces = faces;
    mesh.verts = verts;
    mesh.uvs = uvs;
    return mesh;
}

void orgfx3d_mesh_texture_size(orgfx_mesh* mesh,
                               unsigned int width,
                               unsigned int height)
{
    orgfx_point2 *uvs = mesh->uvs;
    unsigned int numUvs = mesh->numUvs;

    unsigned int i;
    for(i = 0; i < numUvs; i++)
    {
        uvs[i].x *= width;
        uvs[i].y = 1.0 - uvs[i].y; // Mirror v coordinate
        uvs[i].y *= height;
    }
}

void orgfx3d_draw_mesh(orgfx_mesh *mesh, int filled, int textured)
{
    if(textured)
        orgfx_enable_tex0(1);
    else
        orgfx_enable_tex0(0);

    orgfx_enable_transform(1);

    orgfx_matrix m = orgfx3d_identity();
    m = orgfx3d_rotateX(m, mesh->rotation.x);
    m = orgfx3d_rotateY(m, mesh->rotation.y);
    m = orgfx3d_rotateZ(m, mesh->rotation.z);
    m = orgfx3d_scale(m, mesh->scale);
    m = orgfx3d_translate(m, mesh->translation);
    orgfx3d_set_matrix(m);

    int f;
    for(f = 0; f < mesh->numFaces; f++)
    {
        orgfx_point3 p1 = mesh->verts[mesh->faces[f].p1];
        orgfx_point3 p2 = mesh->verts[mesh->faces[f].p2];
        orgfx_point3 p3 = mesh->verts[mesh->faces[f].p3];

        // Handle coloring
        if(textured)
        {
            orgfx_point2 uv1 = mesh->uvs[mesh->faces[f].uv1];
            orgfx_point2 uv2 = mesh->uvs[mesh->faces[f].uv2];
            orgfx_point2 uv3 = mesh->uvs[mesh->faces[f].uv3];

            orgfx_uv(uv1.x, uv1.y,
                     uv2.x, uv2.y,
                     uv3.x, uv3.y);
        }
        else
        {
            orgfx_set_colors(mesh->faces[f].color1,
                             mesh->faces[f].color2,
                             mesh->faces[f].color3);
        }

        if(filled)
            orgfx_triangle3d(p1.x*FIXEDW, p1.y*FIXEDW, p1.z*FIXEDW,
                             p2.x*FIXEDW, p2.y*FIXEDW, p2.z*FIXEDW,
                             p3.x*FIXEDW, p3.y*FIXEDW, p3.z*FIXEDW,
                             1);
        else
        {
            orgfx_line3d(p1.x*FIXEDW, p1.y*FIXEDW, p1.z*FIXEDW, p2.x*FIXEDW, p2.y*FIXEDW, p2.z*FIXEDW);
            orgfx_line3d(p2.x*FIXEDW, p2.y*FIXEDW, p2.z*FIXEDW, p3.x*FIXEDW, p3.y*FIXEDW, p3.z*FIXEDW);
            orgfx_line3d(p3.x*FIXEDW, p3.y*FIXEDW, p3.z*FIXEDW, p1.x*FIXEDW, p1.y*FIXEDW, p1.z*FIXEDW);
        }
    }

    orgfx_enable_transform(0);
}
