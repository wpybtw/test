nvcc tensor_max.cu -o tensor_max --generate-code=arch=compute_86,code=[compute_86,sm_86] --generate-code=arch=compute_70,code=[compute_70,sm_70]  -O3 -forward-unknown-to-host-compiler -fopenmp

./tensor_max
python max.py