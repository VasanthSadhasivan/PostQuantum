import numpy
from ntt_tools import *

n = 256
q = 1049089
f = numpy.poly1d([1] + [0] * (n - 1) + [1])
working_mod = find_modulus(n, q)
primitive_root = find_primitive_root(n, working_mod - 1, working_mod)
W = [(primitive_root**i)%working_mod for i in range(n)]
PHI = [(207929**i) % q for i in range(n)]
iPHI = [reciprocal(phi, q) for phi in PHI]
mod = find_modulus(n, q)
root = find_primitive_root(n, mod - 1, mod)

def poly_add(l1, l2):
    return list(([int(i) % q for i in list(numpy.poly1d(list(l1)) + numpy.poly1d(list(l2)))]))


def poly_mult(l1, l2):
    return list(([int(i) % q for i in list(numpy.polydiv(numpy.poly1d(list(l1)) * numpy.poly1d(list(l2)), f)[1])]))


def poly_neg(l1):
    return [(-1 * i) % q for i in l1]


def poly_decode(l1):
    return [1 if i > q//2 else 0 for i in l1]

def poly_phi(l1):
    return [(PHI[::-1][i] * l1[i]) % q for i in range(n)]

def poly_iphi(l1):
    return [(iPHI[::-1][i] * l1[i]) % q for i in range(n)]

def poly_ntt(l1):
    return transform(l1[::-1], root, mod)[::-1]

def poly_intt(l1):
    return inverse_transform(l1[::-1], root, mod)[::-1]

def poly_point_mult(l1, l2):
    return [(l2[i] * l1[i]) % q for i in range(n)]

def from_testbench_str(l):
     l = l.split(' ')
     list1 = [int(i, 16) for i in l]
     return list1

def to_testbench_str(l):
    for i in range(n):
        print('{0:0{1}X}'.format((l[i]) % q, 16), end=' ')
    print()

def generate_uniform(prev_uniform):
    uniform = [prev_uniform[-1]]
    for i in range(255):
        uniform.append(lfsr(uniform[-1]))
    return uniform

def generate_gaussian(uniform):
    gaussian = []

    for uniform_number in uniform:
        if uniform_number < 1481:
            gaussian_number = 10
        elif uniform_number < 3781:
            gaussian_number = 9
        elif uniform_number < 8881:
            gaussian_number = 8
        elif uniform_number < 19221:
            gaussian_number = 7
        elif uniform_number < 38441:
            gaussian_number = 6
        elif uniform_number < 71101:
            gaussian_number = 5
        elif uniform_number < 121931:
            gaussian_number = 4
        elif uniform_number < 194341:
            gaussian_number = 3
        elif uniform_number < 288751:
            gaussian_number = 2
        elif uniform_number < 401441:
            gaussian_number = 1
        elif uniform_number < 647641:
            gaussian_number = 0
        elif uniform_number < 760321:
            gaussian_number = 1
        elif uniform_number < 854741:
            gaussian_number = 2
        elif uniform_number < 927141:
            gaussian_number = 3
        elif uniform_number < 977981:
            gaussian_number = 4
        elif uniform_number < 1010641:
            gaussian_number = 5
        elif uniform_number < 1029851:
            gaussian_number = 6
        elif uniform_number < 1040201:
            gaussian_number = 7
        elif uniform_number < 1045301:
            gaussian_number = 8
        elif uniform_number < 1047601:
            gaussian_number = 9
        else:
            gaussian_number = 10
        gaussian.append(gaussian_number)
    return gaussian

DONT_CHECK = '''1111111111111111 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000 0000000000000000'''

message = [0, 1049089//2, 0, 1049089//2] + [0 for i in range(252)]

prev_uniform = [1]

# Key Init
a = generate_uniform([1])
prev_uniform = generate_uniform(prev_uniform)
s = generate_gaussian(prev_uniform)
prev_uniform = generate_uniform(prev_uniform)
e = generate_gaussian(prev_uniform)

y = poly_add(poly_mult(a, s), e)
sk = s

print("Key Initialization")
print(DONT_CHECK)
print(DONT_CHECK)
print(DONT_CHECK)
print(DONT_CHECK)
to_testbench_str(s)
to_testbench_str(a)
to_testbench_str(poly_phi(a))
to_testbench_str(poly_phi(s))
to_testbench_str(poly_ntt(poly_phi(a)))
to_testbench_str(poly_ntt(poly_phi(s)))
to_testbench_str(poly_point_mult(poly_ntt(poly_phi(a)), poly_ntt(poly_phi(s))))
to_testbench_str(poly_intt(poly_point_mult(poly_ntt(poly_phi(a)), poly_ntt(poly_phi(s)))))
to_testbench_str(poly_iphi(poly_intt(poly_point_mult(poly_ntt(poly_phi(a)), poly_ntt(poly_phi(s))))))
#to_testbench_str(poly_mult(a, s))
to_testbench_str(poly_add(poly_mult(a, s), e))
to_testbench_str(a)
to_testbench_str(y)
to_testbench_str(sk)

# Encryption
prev_uniform = [1]
prev_uniform = generate_uniform(prev_uniform)
r = generate_gaussian(prev_uniform)
prev_uniform = generate_uniform(prev_uniform)
e1 = generate_gaussian(prev_uniform)
prev_uniform = generate_uniform(prev_uniform)
e2 = generate_gaussian(prev_uniform)
a_hat = poly_add(poly_mult(a, r), e1)
b_hat = poly_add(poly_add(poly_mult(y, r), e2), message)

print("Encryption")
print(DONT_CHECK)
print(DONT_CHECK)
print(DONT_CHECK)
print(DONT_CHECK)
print(DONT_CHECK)
print(DONT_CHECK)
to_testbench_str(r)
to_testbench_str(poly_phi(a))
to_testbench_str(poly_phi(r))
to_testbench_str(poly_ntt(poly_phi(a)))
to_testbench_str(poly_ntt(poly_phi(r)))
to_testbench_str(poly_point_mult(poly_ntt(poly_phi(r)), poly_ntt(poly_phi(a))))
to_testbench_str(poly_intt(poly_point_mult(poly_ntt(poly_phi(r)), poly_ntt(poly_phi(a)))))
to_testbench_str(poly_iphi(poly_intt(poly_point_mult(poly_ntt(poly_phi(r)), poly_ntt(poly_phi(a))))))
#to_testbench_str(poly_mult(a, r))
to_testbench_str(poly_add(poly_mult(a, r), e1))

to_testbench_str(poly_phi(y))
to_testbench_str(poly_phi(r))
to_testbench_str(poly_ntt(poly_phi(y)))
to_testbench_str(poly_ntt(poly_phi(r)))
to_testbench_str(poly_point_mult(poly_ntt(poly_phi(r)), poly_ntt(poly_phi(y))))
to_testbench_str(poly_intt(poly_point_mult(poly_ntt(poly_phi(r)), poly_ntt(poly_phi(y)))))
to_testbench_str(poly_iphi(poly_intt(poly_point_mult(poly_ntt(poly_phi(r)), poly_ntt(poly_phi(y))))))
#to_testbench_str(poly_mult(y, r))
to_testbench_str(poly_add(poly_mult(y, r), e2))
print(DONT_CHECK)
to_testbench_str(message)
to_testbench_str(poly_add(poly_add(poly_mult(y, r), e2), message))
to_testbench_str(a_hat)
to_testbench_str(b_hat)

# Decryption
message = poly_add(poly_neg(poly_mult(a_hat, sk)), b_hat)

print("Decryption")
print(DONT_CHECK)
print(DONT_CHECK)
print(DONT_CHECK)
to_testbench_str(poly_phi(a_hat))
to_testbench_str(poly_phi(sk))
to_testbench_str(poly_ntt(poly_phi(a_hat)))
to_testbench_str(poly_ntt(poly_phi(sk)))
to_testbench_str(poly_point_mult(poly_ntt(poly_phi(sk)),poly_ntt(poly_phi(a_hat))))
to_testbench_str(poly_intt(poly_point_mult(poly_ntt(poly_phi(sk)),poly_ntt(poly_phi(a_hat)))))
to_testbench_str(poly_iphi(poly_intt(poly_point_mult(poly_ntt(poly_phi(sk)),poly_ntt(poly_phi(a_hat))))))
#to_testbench_str(poly_mult(a_hat, sk))
to_testbench_str(poly_neg(poly_mult(a_hat, sk)))
to_testbench_str(poly_add(b_hat, poly_neg(poly_mult(a_hat, sk))))