// Diego Andrés González Idárraga

#ifndef gpu_matrix_h
#define gpu_matrix_h

#include "gpu_vector.h"

struct gpu_matrix {
    float _11, _12, _13, _14,
          _21, _22, _23, _24,
          _31, _32, _33, _34,
          _41, _42, _43, _44;

    gpu_matrix() {}
    gpu_matrix(const float &__11, const float &__12, const float &__13, const float &__14,
               const float &__21, const float &__22, const float &__23, const float &__24,
               const float &__31, const float &__32, const float &__33, const float &__34,
               const float &__41, const float &__42, const float &__43, const float &__44) : _11(__11), _12(__12), _13(__13), _14(__14),
                                                                                             _21(__21), _22(__22), _23(__23), _24(__24),
                                                                                             _31(__31), _32(__32), _33(__33), _34(__34),
                                                                                             _41(__41), _42(__42), _43(__43), _44(__44) {}
    static gpu_matrix i();
    static gpu_matrix s(const gpu_vector3 &);
    static gpu_matrix t(const gpu_vector3 &);
    static gpu_matrix rx(const float &);
    static gpu_matrix ry(const float &);
    static gpu_matrix rz(const float &);
    static gpu_matrix p(const float &, const float &, const float &, const float &);
    gpu_matrix operator+() const;
    gpu_matrix operator-() const;
    gpu_matrix operator*(const float &) const;
    gpu_matrix operator/(const float &) const;
    gpu_matrix operator+(const gpu_matrix &) const;
    gpu_matrix operator-(const gpu_matrix &) const;
    gpu_matrix operator*(const gpu_matrix &) const;
    gpu_matrix &operator*=(const float &);
    gpu_matrix &operator/=(const float &);
    gpu_matrix &operator+=(const gpu_matrix &);
    gpu_matrix &operator-=(const gpu_matrix &);
    gpu_matrix &operator*=(const gpu_matrix &);
};
gpu_matrix operator*(const float &, const gpu_matrix &);
gpu_vector4 operator*(const gpu_vector4 &, const gpu_matrix &);

#endif
