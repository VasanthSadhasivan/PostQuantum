import numpy
import sys

n = 256
q = 1049089
f = numpy.poly1d([1] + [0] * (n - 1) + [1])

def poly_add(l1, l2):
    return list(([int(i)%q for i in list(numpy.poly1d(list((l1))) + numpy.poly1d(list((l2))))]))


def poly_mult(l1, l2):
    return list(([int(i)%q for i in list(numpy.polydiv(numpy.poly1d(list((l1))) * numpy.poly1d(list((l2))), f)[1])]))

UNENCRYPTED_STR = "unencrypted"
ENCRYPTED_STR = "encrypted"
KEY_STR = "key"


if len(sys.argv) != 2:
    print("Usage: python3 sim_rlwe_main_encrypt.py %s/%s/%s" % (UNENCRYPTED_STR, ENCRYPTED_STR, KEY_STR))
    exit()


UNIFORM = [i for i in range(n)]
GAUSSIAN = [1 for i in range(n)]


if sys.argv[1] == KEY_STR:
    private_key = GAUSSIAN.copy()
    public1_key = UNIFORM.copy()

    public2_key = poly_add(poly_mult(public1_key, private_key), GAUSSIAN)

    for i in range(n):
        print(str('{:x}'.format(public1_key[i])).zfill(16), end = ' ')
        print(str('{:x}'.format(public2_key[i])).zfill(16), end = ' ')
        print(str('{:x}'.format(private_key[i])).zfill(16), end = ' ')

elif sys.argv[1] == UNENCRYPTED_STR:
    for i in range(n):
        print(str('{:x}'.format(i % 2)).zfill(16), end = ' ')

elif sys.argv[1] == ENCRYPTED_STR:
    unencrypted_data = [0 for i in range(n)]

    for i in range(n):
        unencrypted_data[i] = (q // 2) * (i % 2)

    r = GAUSSIAN.copy()
    e1 = GAUSSIAN.copy()
    e2 = GAUSSIAN.copy()

    #print(e1)

    private_key = GAUSSIAN.copy()
    public1_key = UNIFORM.copy()

    public2_key = poly_add(poly_mult(private_key, public1_key), GAUSSIAN.copy())

    encrypted1_data = poly_add(poly_mult(public1_key, r), e1)

    encrypted2_data = poly_add(poly_add(poly_mult(public2_key,r), e2), unencrypted_data)
    print("y:", public2_key)
    for i in range(n):
        #print(str('{:x}'.format(encrypted1_data[i])).zfill(16), end = ' ')
        #print(str('{:x}'.format(encrypted2_data[i])).zfill(16), end = ' ')
        continue


