#include <iostream>
#include <fstream>
#include "vec3.h"
#include "ray.h"
#include <cmath>
#include "random.h"

struct sphere {
    vec3 center;
    float radius;
    vec3 sphere_color;
};

__device__ float hit_sphere(const sphere& s, const ray& r) {
    vec3 oc = r.origin() - s.center; // A - C
    float a = dot(r.direction(), r.direction());
    float b = 2.0f * dot(oc, r.direction());
    float c = dot(oc,oc) -  s.radius*s.radius;
    float delta = b*b - 4*a*c;
    if (delta > 0) {
        return (-b - sqrt(delta)) /(2*a);
    }
    else return -1.0f;
}

__global__ void render(int width, int hight, float *fb, sphere *s, int num_spheres) {
    int col = threadIdx.x + blockIdx.x * blockDim.x;
    int line = threadIdx.y + blockIdx.y * blockDim.y;
    if ((col >= width) || (line >= hight)) return;
    int pixel_index = (line * width + col) * 3;
    unsigned int seed = pixel_index;
    vec3 origin(0.0f,0.0f,0.0f);
    vec3 horizontal(2.0f,0.0f,0.0f);
    vec3 vertical(0.0f,2.0f,0.0f);
    vec3 lower_left_corner(-1.0f, -1.0f, -1.0f);

    float sum_r = 0.0f, sum_g = 0.0f, sum_b = 0.0f;

    int samples = 550;
    for (int s_idx = 0; s_idx < samples; s_idx++) {
        float u = (float(col) + random_float(&seed))/float(width);
        float v = (float(line) + random_float(&seed))/float(hight);

        ray r(origin,lower_left_corner + horizontal * u + vertical * v - origin);

        ray cur_ray = r;
        vec3 attenuation(1.0f, 1.0f, 1.0f);

        float ray_r = 0.0f, ray_g = 0.0f, ray_b = 0.0f;

        for (int bounce=0; bounce<20; bounce++) {
            float closest_t = 99999.0f;
            int hit_index = -1;

            for (int i=0; i<num_spheres; i++) {
                float t = hit_sphere(s[i],cur_ray);

                if (t > 0.01f && t < closest_t) {
                    closest_t = t;
                    hit_index = i;
                }
            }
            if (hit_index != -1) {
                point3 hit = cur_ray.at(closest_t);
                vec3 point_direction = unit_vector(hit - s[hit_index].center);

                point3 target = hit + point_direction + random_in_unit_sphere(&seed);
                cur_ray = ray(hit,target - hit);
                attenuation = vec3(attenuation.x() * s[hit_index].sphere_color.x(),
                    attenuation.y() * s[hit_index].sphere_color.y(),
                    attenuation.z() * s[hit_index].sphere_color.z());
            }
            else {
                vec3 unit_direction = unit_vector(cur_ray.direction());
                float t = 0.5f * (unit_direction.y() + 1.0f);

                color pixel_color = color(1.0f, 1.0f, 1.0f) * (1.0f - t) + color(0.5f, 0.7f, 1.0f) * t;

                ray_r = pixel_color.r() * attenuation.r();
                ray_g = pixel_color.g() * attenuation.g();
                ray_b = pixel_color.b() * attenuation.b();
                break;
            }
        }
        sum_r = sum_r + ray_r;
        sum_g = sum_g + ray_g;
        sum_b = sum_b + ray_b;
    }
    fb[pixel_index] = sqrt(sum_r / float(samples)); //Gamma
    fb[pixel_index + 1] = sqrt(sum_g / float(samples));
    fb[pixel_index + 2] = sqrt(sum_b / float(samples));
}
int main() {
    int width = 256;
    int hight = 256;
    int num_pixels = width * hight;
    size_t fb_size = num_pixels * 3 * sizeof(float);

    float *fb;
    cudaMallocManaged(&fb, fb_size); //ładowanie pamięci dla wskaźnika

    sphere *d_spheres;
    cudaMallocManaged(&d_spheres, 2 * sizeof(sphere));

    d_spheres[0].center = vec3(0.0f, 0.0f, -1.0f);
    d_spheres[0].radius = 0.3f;
    d_spheres[0].sphere_color = vec3(0.8f,0.1f,0.1f);
    d_spheres[1].center = vec3(0.0f, -100.5f, -1.0f);
    d_spheres[1].radius = 100.0f;
    d_spheres[1].sphere_color = vec3(0.2f, 0.8f, 0.2f);

    dim3 blocks(width / 8, hight / 8);
    dim3 threads(8, 8);

    render<<<blocks,threads>>>(width,hight,fb, d_spheres, 2);

    cudaDeviceSynchronize();
    std::ofstream file("obrazek4.5.ppm");
    file << "P3\n" << width << " " << hight << "\n255\n";

    for (int j = hight - 1; j >= 0; j--) {
        for (int i = 0; i < width; i++) {
             size_t pixel_index = j * width * 3 + i * 3;

             color pixel_color(fb[pixel_index], fb[pixel_index+1], fb[pixel_index+2]);
             color final_pixel_color = pixel_color * 255.99f;

             int ir = static_cast<int>(final_pixel_color.r());
             int ig = static_cast<int>(final_pixel_color.g());
             int ib = static_cast<int>(final_pixel_color.b());

             file << ir << " " << ig << " " << ib << "\n";
        }
    }
    file.close();

    cudaFree(fb);
    cudaFree(d_spheres);

    std::cout << "Zrobione!" << std::endl;
    return 0;
}