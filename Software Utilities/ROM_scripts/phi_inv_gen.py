from ntt_tools import * 
from efficient_ntt import *

n = 256
q = 1049089

working_mod = find_modulus(n, q)
primitive_root = find_primitive_root(n, working_mod - 1, working_mod)
W = [(primitive_root**i)%working_mod for i in range(n)]
#PHI = [modular_sqrt(w, q) for w in W]
PHI = [(207929**i)%q for i in range(len(W))]
iPHI = [reciprocal(phi, q) % q for phi in PHI]

#'''FIGURE OUT WHY TF I NEED TO DO THE FOLLOWING:'''
#iPHI = [iPHI[i]%q if i == 0 else (-iPHI[i])%q for i in range(len(iPHI))]

iPHI = [str('{:x}'.format(element).zfill(16)) for element in iPHI]

print('\n'.join(iPHI))
