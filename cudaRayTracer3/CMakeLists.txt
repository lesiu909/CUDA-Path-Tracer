cmake_minimum_required(VERSION 3.20)

set(CMAKE_CUDA_FLAGS "-allow-unsupported-compiler -D_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH" CACHE STRING "" FORCE)

project(cudaRayTracer LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

add_executable(cudaRayTracer main.cu
        main.cu
        vec3.h
        ray.h
        random.h)
add_compile_options(-Wall)