import numpy
import sys

if len(sys.argv) != 2:
    print("Usage: python3 sim_poly_mult_gen.py input/output")
    exit()

n = 256
q = 1049089

polynomial_in_length = 254

poly1 = [i for i in range(polynomial_in_length)] + (n-polynomial_in_length)*[0]
poly2 = [i for i in range(polynomial_in_length)] + (n-polynomial_in_length)*[0]
poly1 = numpy.poly1d([x for x in reversed(poly1)])
poly2 = numpy.poly1d([x for x in reversed(poly2)])

f = numpy.poly1d([1] + [0] * (n - 1) + [1])

numpy_result = list(reversed([int(i) for i in list(numpy.fmod(numpy.polydiv(numpy.fmod((poly1 * poly2), q), f)[1], q))])) + (n - len(list(numpy.fmod(numpy.polydiv(numpy.fmod((poly1 * poly2), q), f)[1], q))))*[0]
numpy_result = [i % q for i in numpy_result]

if sys.argv[1] == 'input':
    for i in range(n):
        print(str('{:x}'.format(poly1[i])).zfill(16), end=' ')
        print(str('{:x}'.format(poly2[i])).zfill(16), end=' ')

else:
    for i in range(n):
        print(str('{:x}'.format(numpy_result[i])).zfill(16), end=' ')
