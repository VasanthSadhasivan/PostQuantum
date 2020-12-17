from ntt_tools import *
import numpy
from sympy import ntt, intt
n = 256
q = 1049089


working_mod = find_modulus(n, q)
primitive_root = find_primitive_root(n, working_mod - 1, working_mod)
W = [(primitive_root**i)%working_mod for i in range(n)]
#PHI = [modular_sqrt(w, q) for w in W]
PHI = [(207929**i)%q for i in range(n)]
iPHI = [reciprocal(phi, q) for phi in PHI]

#'''FIGURE OUT WHY TF I NEED TO DO THE FOLLOWING:'''
#iPHI = [iPHI[i]%q if i == 0 else (-iPHI[i])%q for i in range(len(iPHI))]

mod = find_modulus(n, q)
root = find_primitive_root(n, mod - 1, mod)

polynomial_in_length = 256

poly1 = [1 for i in range(polynomial_in_length)] + (n-polynomial_in_length)*[0]
poly2 = [polynomial_in_length-1-i for i in range(polynomial_in_length)] + (n-polynomial_in_length)*[0]

phi_multiplied1 = [(PHI[i] * poly1[i]) % q for i in range(n)]
phi_multiplied2 = [(PHI[i] * poly2[i]) % q for i in range(n)]

ntt1 = transform(phi_multiplied1, root, mod)
ntt2 = transform(phi_multiplied2, root, mod)


ntt_mult = [(ntt1[i] * ntt2[i]) % q for i in range(n)]

intt_mult = inverse_transform(ntt_mult, root, mod)

phi_inv_mult = [(iPHI[i] * intt_mult[i]) % q for i in range(n)]

print("Input 1:\t\t", poly1)
print("Input 2:\t\t", poly2)
print("NTT Output:\t\t", phi_inv_mult)


f = numpy.poly1d([1] + [0] * (n - 1) + [1])
poly1 = numpy.poly1d(numpy.array([x for x in reversed(poly1)], dtype=object))
poly2 = numpy.poly1d(numpy.array([x for x in reversed(poly2)], dtype=object))
numpy_result = list(reversed([int(i) for i in list(mymod(numpy.polydiv(mymod((poly1 * poly2), q), f)[1], q))])) + (n - len(list(mymod(numpy.polydiv(mymod((poly1 * poly2), q), f)[1], q))))*[0]
numpy_result = [i % q for i in numpy_result]

print("Numpy Output:\t", numpy_result)