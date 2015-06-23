// Diego Andrés González Idárraga

#ifndef gpu_vector_h
#define gpu_vector_h

#include <cmath>

//gpu_vector2

struct gpu_vector2 {
	float x, y;

	gpu_vector2() {}
	gpu_vector2(const float &X, const float &Y) : x(X), y(Y) {}
	gpu_vector2 operator+() const;
	gpu_vector2 operator-() const;
	gpu_vector2 operator*(const float &) const;
	gpu_vector2 operator/(const float &) const;
	gpu_vector2 operator+(const gpu_vector2 &) const;
	gpu_vector2 operator-(const gpu_vector2 &) const;
	gpu_vector2 operator*(const gpu_vector2 &) const;
	gpu_vector2 operator/(const gpu_vector2 &) const;
	gpu_vector2 &operator*=(const float &);
	gpu_vector2 &operator/=(const float &);
	gpu_vector2 &operator+=(const gpu_vector2 &);
	gpu_vector2 &operator-=(const gpu_vector2 &);
	gpu_vector2 &operator*=(const gpu_vector2 &);
	gpu_vector2 &operator/=(const gpu_vector2 &);
	float length() const;
	bool operator==(const gpu_vector2 &) const;
	bool operator!=(const gpu_vector2 &) const;
};
gpu_vector2 operator*(const float &, const gpu_vector2 &);
float dot(const gpu_vector2 &, const gpu_vector2 &);

//gpu_vector3

struct gpu_vector3 {
	float x, y, z;

	gpu_vector3() {}
	gpu_vector3(const float &X, const float &Y, const float &Z) : x(X), y(Y), z(Z) {}
	gpu_vector3 operator+() const;
	gpu_vector3 operator-() const;
	gpu_vector3 operator*(const float &) const;
	gpu_vector3 operator/(const float &) const;
	gpu_vector3 operator+(const gpu_vector3 &) const;
	gpu_vector3 operator-(const gpu_vector3 &) const;
	gpu_vector3 operator*(const gpu_vector3 &) const;
	gpu_vector3 operator/(const gpu_vector3 &) const;
	gpu_vector3 &operator*=(const float &);
	gpu_vector3 &operator/=(const float &);
	gpu_vector3 &operator+=(const gpu_vector3 &);
	gpu_vector3 &operator-=(const gpu_vector3 &);
	gpu_vector3 &operator*=(const gpu_vector3 &);
	gpu_vector3 &operator/=(const gpu_vector3 &);
	float length() const;
	bool operator==(const gpu_vector3 &) const;
	bool operator!=(const gpu_vector3 &) const;
};
gpu_vector3 operator*(const float &, const gpu_vector3 &);
float dot(const gpu_vector3 &, const gpu_vector3 &);
gpu_vector3 cross(const gpu_vector3 &, const gpu_vector3 &);

//gpu_vector4

struct gpu_vector4 {
	float x, y, z, w;

	gpu_vector4() {}
	gpu_vector4(const float &X, const float &Y, const float &Z, const float &W) : x(X), y(Y), z(Z), w(W) {}
	gpu_vector4 operator+() const;
	gpu_vector4 operator-() const;
	gpu_vector4 operator*(const float &) const;
	gpu_vector4 operator/(const float &) const;
	gpu_vector4 operator+(const gpu_vector4 &) const;
	gpu_vector4 operator-(const gpu_vector4 &) const;
	gpu_vector4 operator*(const gpu_vector4 &) const;
	gpu_vector4 operator/(const gpu_vector4 &) const;
	gpu_vector4 &operator*=(const float &);
	gpu_vector4 &operator/=(const float &);
	gpu_vector4 &operator+=(const gpu_vector4 &);
	gpu_vector4 &operator-=(const gpu_vector4 &);
	gpu_vector4 &operator*=(const gpu_vector4 &);
	gpu_vector4 &operator/=(const gpu_vector4 &);
	float length() const;
	bool operator==(const gpu_vector4 &) const;
	bool operator!=(const gpu_vector4 &) const;
};
gpu_vector4 operator*(const float &, const gpu_vector4 &);
float dot(const gpu_vector4 &, const gpu_vector4 &);

#endif
