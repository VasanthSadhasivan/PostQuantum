import numpy
import sys
import random
from polyreduce_helper import *

if len(sys.argv) != 2:
    print("Usage: python3 sim_polyreduce_gen.py input/output")
    exit()

n = 256
q = 1049089

# SETUP
poly1 = [i for i in range(n-1)] + [0]
poly2 = [1, 1] + [0 for i in range(n-2)]

output_expected = list(poly_reduce_extended_euclidean(numpy.poly1d([x for x in reversed(poly1)]), numpy.poly1d([x for x in reversed(poly2)]))[0])

numpy_result = output_expected + [0 for i in range(n - len(output_expected))]
numpy_result = [int(i) % q for i in numpy_result]

if sys.argv[1] == 'input':
    for i in range(n):
        print(str('{:x}'.format(poly1[i])).zfill(16), end=' ')
        print(str('{:x}'.format(poly2[i])).zfill(16), end=' ')

else:
    for i in range(n):
        print(str('{:x}'.format(numpy_result[i])).zfill(16), end=' ')
