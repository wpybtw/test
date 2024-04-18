#include <stdio.h>
#include <cuda.h>
#include <vector>
#include <algorithm>
#include <iostream>
#include <omp.h>
#include <assert.h>

#include "timer.h"

const size_t m = 10ull * 1000 * 1000;
const int n = 64;

__global__ void kernel(float *data, float *output)
{

    size_t tid = blockDim.x * blockIdx.x + threadIdx.x;
    size_t ltid = threadIdx.x;
    size_t offset = blockDim.x * blockIdx.x;
    __shared__ float tmp[n][n];
    float tmax = -1000;

    if (tid < m)
    {
        for (int i = 0; i < n; i++)
        {
            tmp[i][ltid] = data[(offset + i) * n + ltid];
        }
        __syncthreads();

        for (int i = 0; i < n; i++)
        {
            tmax = fmax(tmp[ltid][(i + ltid) % n], tmax);
            // tmax = fmax(tmp[ltid][i], tmax);
        }
        output[tid] = tmax;
    }
}

void check(float *a, float *b)
{

#pragma omp parallel for
    for (int i = 0; i < m; i++)
    {
        float acc = -100;
        for (size_t j = 0; j < n; j++)
        {
            acc = fmax(acc, a[i * n + j]);
        }

        if (abs(acc - b[i]) > 0.001f)
        {
            std::cout << i << " " << acc << " " << b[i] << std::endl;
            // break;
        }
    }
    std::cout<<" verified "<<std::endl;
}

int main()
{
    std::srand(0);
    using T = float;
    std::vector<T> vA;
    std::vector<T> vB;

    size_t size_a = m * n * sizeof(T);
    size_t size_b = m * sizeof(T);

    std::cout << "using m=" << m << " n=" << n << std::endl;

    vA.resize(m * n);
    vB.resize(m);

    T *a, *b;
    cudaMalloc(&a, size_a);
    cudaMalloc(&b, size_b);

    std::generate(vA.begin(), vA.end(), std::rand);

    cudaMemcpy(a, vA.data(), size_a, cudaMemcpyHostToDevice);
    cudaMemcpy(b, vB.data(), size_b, cudaMemcpyHostToDevice);
    cudaDeviceSynchronize();
    {
        Stopwatch t;
        kernel<<<m / n + 1, n>>>(a, b);
        cudaDeviceSynchronize();
        int ms = t.Finish();
        std::cout << " CUDA kernel takes " << ms << " ms" << std::endl;
    }

    cudaMemcpy(vB.data(), b, size_b, cudaMemcpyDeviceToHost);

    check(vA.data(), vB.data());

    return 0;
}