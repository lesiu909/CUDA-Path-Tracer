//
// Created by lesiu on 16.03.2026.
//

#ifndef CUDARAYTRACER_RAY_H
#define CUDARAYTRACER_RAY_H
#include "vec3.h"
#pragma once

// P(t) = A + t*b
class ray {
public:
    point3 orig; //start (A)
    vec3 dir; //kierunek (b)

    __host__ __device__ ray() {}
    __host__ __device__ ray(const point3& origin, const vec3& direction) : orig(origin), dir(direction) {}

    __host__ __device__ point3 origin() const {return  orig;}
    __host__ __device__ vec3 direction() const {return dir;}

    __host__ __device__ point3 at(float t) const { // t = czas
        return orig + dir * t;
    }
};



#endif //CUDARAYTRACER_RAY_H