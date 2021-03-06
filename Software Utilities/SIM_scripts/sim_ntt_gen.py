from ntt_tools import *
import numpy
import sys

if len(sys.argv) != 2:
    print("Usage: python3 sim_poly_mult_gen.py input/output")
    exit()

n = 256
q = 1049089

mod = find_modulus(n, q)
root = find_primitive_root(n, mod - 1, mod)

polynomial_in_length = 254

in_data = [i for i in range(polynomial_in_length)] + (n-polynomial_in_length)*[0]

ntt_data = transform(in_data, root, mod)


if sys.argv[1] == 'input':
    for i in range(n):
        print(str('{:x}'.format(in_data[i])).zfill(16), end=' ')

else:
    for i in range(n):
        print(str('{:x}'.format(ntt_data[i])).zfill(16), end=' ')