//
// Created by lesiu on 12.03.2026.
//

#ifndef CUDARAYTRACER_VEC3_H
#define CUDARAYTRACER_VEC3_H
#pragma once

class vec3 {
public:
    float e[3];

    __host__ __device__ vec3() : e{0,0,0} {}
    __host__ __device__ vec3(float e0, float e1, float e2) : e{e0,e1,e2} {}

    __host__ __device__ inline float r() const { return e[0]; }
    __host__ __device__ inline float g() const { return e[1]; }
    __host__ __device__ inline float b() const { return e[2]; }

    __host__ __device__ inline float x() const { return e[0]; }
    __host__ __device__ inline float y() const { return e[1]; }
    __host__ __device__ inline float z() const { return e[2]; }


     __host__ __device__ inline vec3 operator+(const vec3 &v) const {
        return vec3(this->e[0] + v.e[0],this->e[1] + v.e[1], this->e[2] + v.e[2]);
    }

     __host__ __device__ inline vec3 operator-(const vec3 &v) const {
       return vec3(this->e[0] - v.e[0],this->e[1] - v.e[1], this->e[2] - v.e[2]);
    }

     __host__ __device__ inline vec3 operator*(float t) const {
        return vec3(this->e[0] * t , this->e[1] * t , this->e[2] * t);
    }

    __host__ __device__ inline float length() const {
        return sqrt(e[0]*e[0] + e[1]*e[1] + e[2]*e[2]);
    }
};

__host__ __device__ inline  vec3 unit_vector(vec3 v) { //normalizacja
    return v * (1.0f /v.length());
}

__host__ __device__ inline float dot(const vec3 &v, const vec3 &u) {
    return v.e[0] * u.e[0] + v.e[1] * u.e[1] + v.e[2] * u.e[2];
}

using point3 = vec3;
using color = vec3;


#endif //CUDARAYTRACER_VEC3_H