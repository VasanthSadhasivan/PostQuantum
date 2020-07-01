from ntt_tools import * 
from efficient_ntt import *

n = 256
q = 1049089

working_mod = find_modulus(n, q)
primitive_root = find_primitive_root(n, working_mod - 1, working_mod)
W = [(primitive_root**i)%working_mod for i in range(n)]
modular_root = 207929
#PHI = [str('{:x}'.format(modular_sqrt(w, q))).zfill(16) for w in W]
PHI = [str('{:x}'.format((207929**i)%q)).zfill(16) for i in range(len(W))]

print('\n'.join(PHI))
