import numpy as np


MODULO = 1049089

def egcd(a, b):
    x = 1
    y = 0
    x1 = 0
    y1 = 1
    a1 = a
    b1 = b
    while b1 != 0:
        q = a1 // b1
        (x, x1) = (x1, x - q * x1)
        (y, y1) = (y1, y - q * y1)
        (a1, b1) = (b1, a1 - q * b1)


    return (a1, x, y)

def modinv(a, m):
    g, x, y = egcd(a, m)

    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m

def poly_reduce_numpy(poly1, poly2):
    print(poly1, poly2)
    q, r = np.polydiv(poly1, poly2)
    print(q, r)
    return r

def polymod(poly, modulo):
    return np.poly1d([i % modulo for i in poly.c])

def poly_reduce_extended_euclidean(poly1, poly2):
    quotient = 0

    while poly1.o >= poly2.o and not(poly1.o == 0 and poly1[0] == 0):
        term_to_remove = polymod(polymod(np.poly1d([1] + [0] * (poly1.o - poly2.o)) * poly2 * modinv(poly2[poly2.o], MODULO), MODULO) * poly1[poly1.o], MODULO)
        quotient += polymod(polymod(np.poly1d([1] + [0] * (poly1.o - poly2.o)) * modinv(poly2[poly2.o], MODULO), MODULO) * poly1[poly1.o], MODULO)
        poly1 = polymod(poly1 - term_to_remove, MODULO)

    return poly1, quotient
