// Diego Andrés González Idárraga

#include "gpu_vector.h"

//gpu_vector2

gpu_vector2 gpu_vector2::operator+() const {
	return *this;
}

gpu_vector2 gpu_vector2::operator-() const {
	return gpu_vector2(-x, -y);
}

gpu_vector2 gpu_vector2::operator*(const float &a) const {
	return gpu_vector2(x*a, y*a);
}

gpu_vector2 operator*(const float &x, const gpu_vector2 &v) {
	return v*x;
}

gpu_vector2 gpu_vector2::operator/(const float &a) const {
	return gpu_vector2(x/a, y/a);
}

gpu_vector2 gpu_vector2::operator+(const gpu_vector2 &v) const {
	return gpu_vector2(x+v.x, y+v.y);
}

gpu_vector2 gpu_vector2::operator-(const gpu_vector2 &v) const {
	return gpu_vector2(x-v.x, y-v.y);
}

gpu_vector2 gpu_vector2::operator*(const gpu_vector2 &v) const {
	return gpu_vector2(x*v.x, y*v.y);
}

gpu_vector2 gpu_vector2::operator/(const gpu_vector2 &v) const {
	return gpu_vector2(x/v.x, y/v.y);
}

gpu_vector2 &gpu_vector2::operator*=(const float &a) {
	return *this = *this*a;
}

gpu_vector2 &gpu_vector2::operator/=(const float &a) {
	return *this = *this/a;
}

gpu_vector2 &gpu_vector2::operator+=(const gpu_vector2 &v) {
	return *this = *this+v;
}

gpu_vector2 &gpu_vector2::operator-=(const gpu_vector2 &v) {
	return *this = *this-v;
}

gpu_vector2 &gpu_vector2::operator*=(const gpu_vector2 &v) {
	return *this = *this*v;
}

gpu_vector2 &gpu_vector2::operator/=(const gpu_vector2 &v) {
	return *this = *this/v;
}

float dot(const gpu_vector2 &v1, const gpu_vector2 &v2) {
	return v1.x*v2.x+v1.y*v2.y;
}

float gpu_vector2::length() const {
    return std::sqrt(x*x+y*y);
}

bool gpu_vector2::operator==(const gpu_vector2 &v) const {
    return (x == v.x) && (y == v.y);
}

bool gpu_vector2::operator!=(const gpu_vector2 &v) const {
    return !(*this == v);
}

//gpu_vector3

gpu_vector3 gpu_vector3::operator+() const {
	return *this;
}

gpu_vector3 gpu_vector3::operator-() const {
	return gpu_vector3(-x, -y, -z);
}

gpu_vector3 gpu_vector3::operator*(const float &a) const {
	return gpu_vector3(x*a, y*a, z*a);
}

gpu_vector3 operator*(const float &x, const gpu_vector3 &v) {
	return v*x;
}

gpu_vector3 gpu_vector3::operator/(const float &a) const {
	return gpu_vector3(x/a, y/a, z/a);
}

gpu_vector3 gpu_vector3::operator+(const gpu_vector3 &v) const {
	return gpu_vector3(x+v.x, y+v.y, z+v.z);
}

gpu_vector3 gpu_vector3::operator-(const gpu_vector3 &v) const {
	return gpu_vector3(x-v.x, y-v.y, z-v.z);
}

gpu_vector3 gpu_vector3::operator*(const gpu_vector3 &v) const {
	return gpu_vector3(x*v.x, y*v.y, z*v.z);
}

gpu_vector3 gpu_vector3::operator/(const gpu_vector3 &v) const {
	return gpu_vector3(x/v.x, y/v.y, z/v.z);
}

gpu_vector3 &gpu_vector3::operator*=(const float &a) {
	return *this = *this*a;
}

gpu_vector3 &gpu_vector3::operator/=(const float &a) {
	return *this = *this/a;
}

gpu_vector3 &gpu_vector3::operator+=(const gpu_vector3 &v) {
	return *this = *this+v;
}

gpu_vector3 &gpu_vector3::operator-=(const gpu_vector3 &v) {
	return *this = *this-v;
}

gpu_vector3 &gpu_vector3::operator*=(const gpu_vector3 &v) {
	return *this = *this*v;
}

gpu_vector3 &gpu_vector3::operator/=(const gpu_vector3 &v) {
	return *this = *this/v;
}

float dot(const gpu_vector3 &v1, const gpu_vector3 &v2) {
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;
}

gpu_vector3 cross(const gpu_vector3 &v1, const gpu_vector3 &v2) {
	return gpu_vector3(v1.y*v2.z-v1.z*v2.y, v1.z*v2.x-v1.x*v2.z, v1.x*v2.y-v1.y*v2.x);
}

float gpu_vector3::length() const {
    return std::sqrt(x*x+y*y+z*z);
}

bool gpu_vector3::operator==(const gpu_vector3 &v) const {
    return (x == v.x) && (y == v.y) && (z == v.z);
}

bool gpu_vector3::operator!=(const gpu_vector3 &v) const {
    return !(*this == v);
}

//gpu_vector4

gpu_vector4 gpu_vector4::operator+() const {
	return *this;
}

gpu_vector4 gpu_vector4::operator-() const {
	return gpu_vector4(-x, -y, -z, -w);
}

gpu_vector4 gpu_vector4::operator*(const float &a) const {
	return gpu_vector4(x*a, y*a, z*a, w*a);
}

gpu_vector4 operator*(const float &x, const gpu_vector4 &v) {
	return v*x;
}

gpu_vector4 gpu_vector4::operator/(const float &a) const {
	return gpu_vector4(x/a, y/a, z/a, w/a);
}

gpu_vector4 gpu_vector4::operator+(const gpu_vector4 &v) const {
	return gpu_vector4(x+v.x, y+v.y, z+v.z, w+v.w);
}

gpu_vector4 gpu_vector4::operator-(const gpu_vector4 &v) const {
	return gpu_vector4(x-v.x, y-v.y, z-v.z, w-v.w);
}

gpu_vector4 gpu_vector4::operator*(const gpu_vector4 &v) const {
	return gpu_vector4(x*v.x, y*v.y, z*v.z, w*v.w);
}

gpu_vector4 gpu_vector4::operator/(const gpu_vector4 &v) const {
	return gpu_vector4(x/v.x, y/v.y, z/v.z, w/v.w);
}

gpu_vector4 &gpu_vector4::operator*=(const float &a) {
	return *this = *this*a;
}

gpu_vector4 &gpu_vector4::operator/=(const float &a) {
	return *this = *this/a;
}

gpu_vector4 &gpu_vector4::operator+=(const gpu_vector4 &v) {
	return *this = *this+v;
}

gpu_vector4 &gpu_vector4::operator-=(const gpu_vector4 &v) {
	return *this = *this-v;
}

gpu_vector4 &gpu_vector4::operator*=(const gpu_vector4 &v) {
	return *this = *this*v;
}

gpu_vector4 &gpu_vector4::operator/=(const gpu_vector4 &v) {
	return *this = *this/v;
}

float dot(const gpu_vector4 &v1, const gpu_vector4 &v2) {
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z+v1.w*v2.w;
}

float gpu_vector4::length() const {
    return std::sqrt(x*x+y*y+z*z+w*w);
}

bool gpu_vector4::operator==(const gpu_vector4 &v) const {
    return (x == v.x) && (y == v.y) && (z == v.z) && (w == v.w);
}

bool gpu_vector4::operator!=(const gpu_vector4 &v) const {
    return !(*this == v);
}
