from ntt_tools import * 
from efficient_ntt import *

n = 256
q = 1049089

working_mod = find_modulus(n, q)
primitive_root = find_primitive_root(n, working_mod - 1, working_mod)
W = [(primitive_root**i)%working_mod for i in range(n)]
PHI = [modular_sqrt(w, q) for w in W]
iPHI = [str(reciprocal(phi, q)) for phi in PHI]

print('\n'.join(iPHI))
