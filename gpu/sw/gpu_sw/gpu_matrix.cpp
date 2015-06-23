// Diego Andrés González Idárraga

#include "gpu_matrix.h"

gpu_matrix gpu_matrix::i() {
    return gpu_matrix(1.f, 0.f, 0.f, 0.f,
                      0.f, 1.f, 0.f, 0.f,
                      0.f, 0.f, 1.f, 0.f,
                      0.f, 0.f, 0.f, 1.f);
}

gpu_matrix gpu_matrix::s(const gpu_vector3 &s) {
    return gpu_matrix(s.x, 0.f, 0.f, 0.f,
                      0.f, s.y, 0.f, 0.f,
                      0.f, 0.f, s.z, 0.f,
                      0.f, 0.f, 0.f, 1.f);
}

gpu_matrix gpu_matrix::t(const gpu_vector3 &t) {
    return gpu_matrix(1.f, 0.f, 0.f, 0.f,
                      0.f, 1.f, 0.f, 0.f,
                      0.f, 0.f, 1.f, 0.f,
                      t.x, t.y, t.z, 1.f);
}

gpu_matrix gpu_matrix::rx(const float &rx) {
    return gpu_matrix(1.f,           0.f,          0.f, 0.f,
                      0.f,  std::cos(rx), std::sin(rx), 0.f,
                      0.f, -std::sin(rx), std::cos(rx), 0.f,
                      0.f,           0.f,          0.f, 1.f);
}

gpu_matrix gpu_matrix::ry(const float &ry) {
    return gpu_matrix(std::cos(ry), 0.f, -std::sin(ry), 0.f,
                               0.f, 1.f,           0.f, 0.f,
                      std::sin(ry), 0.f,  std::cos(ry), 0.f,
                               0.f, 0.f,           0.f, 1.f);
}

gpu_matrix gpu_matrix::rz(const float &rz) {
    return gpu_matrix( std::cos(rz), std::sin(rz), 0.f, 0.f,
                      -std::sin(rz), std::cos(rz), 0.f, 0.f,
                                0.f,          0.f, 1.f, 0.f,
                                0.f,          0.f, 0.f, 1.f);
}

gpu_matrix gpu_matrix::p(const float &alpha, const float &aspect_ratio, const float &z_min, const float &z_max) {
    float sx;

    sx = 1.f/std::tan(alpha/2.f);
    return gpu_matrix( sx,             0.f,                  0.f, 0.f,
                      0.f, aspect_ratio*sx,                  0.f, 0.f,
                      0.f,             0.f,    1.f/(z_max-z_min), 1.f,
                      0.f,             0.f, -z_min/(z_max-z_min), 0.f);
}

gpu_matrix gpu_matrix::operator+() const {
    return *this;
}

gpu_matrix gpu_matrix::operator-() const {
    return gpu_matrix(-_11, -_12, -_13, -_14,
                      -_21, -_22, -_23, -_24,
                      -_31, -_32, -_33, -_34,
                      -_41, -_42, -_43, -_44);
}

gpu_matrix gpu_matrix::operator*(const float &x) const {
    return gpu_matrix(_11*x, _12*x, _13*x, _14*x,
                      _21*x, _22*x, _23*x, _24*x,
                      _31*x, _32*x, _33*x, _34*x,
                      _41*x, _42*x, _43*x, _44*x);
}

gpu_matrix operator*(const float &x, const gpu_matrix &m) {
    return m*x;
}

gpu_matrix gpu_matrix::operator/(const float &x) const {
    return gpu_matrix(_11/x, _12/x, _13/x, _14/x,
                      _21/x, _22/x, _23/x, _24/x,
                      _31/x, _32/x, _33/x, _34/x,
                      _41/x, _42/x, _43/x, _44/x);
}

gpu_vector4 operator*(const gpu_vector4 &v, const gpu_matrix &m) {
    return gpu_vector4(v.x*m._11+v.y*m._21+v.z*m._31+v.w*m._41, v.x*m._12+v.y*m._22+v.z*m._32+v.w*m._42, v.x*m._13+v.y*m._23+v.z*m._33+v.w*m._43, v.x*m._14+v.y*m._24+v.z*m._34+v.w*m._44);
}

gpu_matrix gpu_matrix::operator+(const gpu_matrix &m) const {
    return gpu_matrix(_11+m._11, _12+m._12, _13+m._13, _14+m._14,
                      _21+m._21, _22+m._22, _23+m._23, _24+m._24,
                      _31+m._31, _32+m._32, _33+m._33, _34+m._34,
                      _41+m._41, _42+m._42, _43+m._43, _44+m._44);
}

gpu_matrix gpu_matrix::operator-(const gpu_matrix &m) const {
    return gpu_matrix(_11-m._11, _12-m._12, _13-m._13, _14-m._14,
                      _21-m._21, _22-m._22, _23-m._23, _24-m._24,
                      _31-m._31, _32-m._32, _33-m._33, _34-m._34,
                      _41-m._41, _42-m._42, _43-m._43, _44-m._44);
}

gpu_matrix gpu_matrix::operator*(const gpu_matrix &m) const {
    return gpu_matrix(_11*m._11+_12*m._21+_13*m._31+_14*m._41, _11*m._12+_12*m._22+_13*m._32+_14*m._42, _11*m._13+_12*m._23+_13*m._33+_14*m._43, _11*m._14+_12*m._24+_13*m._34+_14*m._44,
                      _21*m._11+_22*m._21+_23*m._31+_24*m._41, _21*m._12+_22*m._22+_23*m._32+_24*m._42, _21*m._13+_22*m._23+_23*m._33+_24*m._43, _21*m._14+_22*m._24+_23*m._34+_24*m._44,
                      _31*m._11+_32*m._21+_33*m._31+_34*m._41, _31*m._12+_32*m._22+_33*m._32+_34*m._42, _31*m._13+_32*m._23+_33*m._33+_34*m._43, _31*m._14+_32*m._24+_33*m._34+_34*m._44,
                      _41*m._11+_42*m._21+_43*m._31+_44*m._41, _41*m._12+_42*m._22+_43*m._32+_44*m._42, _41*m._13+_42*m._23+_43*m._33+_44*m._43, _41*m._14+_42*m._24+_43*m._34+_44*m._44);
}

gpu_matrix &gpu_matrix::operator*=(const float &x) {
    return *this = *this*x;
}

gpu_matrix &gpu_matrix::operator/=(const float &x) {
    return *this = *this/x;
}

gpu_matrix &gpu_matrix::operator+=(const gpu_matrix &m) {
    return *this = *this+m;
}

gpu_matrix &gpu_matrix::operator-=(const gpu_matrix &m) {
    return *this = *this-m;
}

gpu_matrix &gpu_matrix::operator*=(const gpu_matrix &m) {
    return *this = *this*m;
}
