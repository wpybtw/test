
import torch 
import time

m = 10000000
n = 64

a = torch.randn([m,n], dtype = torch.float).to('cuda')
torch.cuda.synchronize()

print(f'Input shape {a.shape}')

t0 = time.time()
val, idx= torch.max(a, dim=1)
torch.cuda.synchronize()
t1 = time.time()

# print(val.shape)
print(f'TORCH max takes {(t1 - t0)*1000:2f} ms')


