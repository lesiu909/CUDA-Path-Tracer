//
// Created by lesiu on 20.03.2026.
//

#ifndef CUDARAYTRACER_RANDOM_H
#define CUDARAYTRACER_RANDOM_H
#pragma once

__device__ inline float random_float(unsigned int *seed) {
    *seed = (*seed * 1664525 + 1013904223);
    return (float)(*seed & 0x00FFFFFF) / (float)0x01000000;
}

__device__ inline float random_float(float min, float max, unsigned int *seed) {
    return min + (max - min) * random_float(seed);
}
__device__ inline vec3 random_in_unit_sphere(unsigned int *seed) {
    while (true) {
        vec3 p(random_float(-1.0f, 1.0f, seed),
               random_float(-1.0f, 1.0f, seed),
               random_float(-1.0f, 1.0f, seed));

        if (p.length() * p.length() >= 1.0f) continue;
        return p;
    }
}

#endif //CUDARAYTRACER_RANDOM_H