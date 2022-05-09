import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import norm
'''
x = []

def lfsr(seed):
    tap_1_index = 2
    tap_2_index = 19

    tap_1_value = (seed >> tap_1_index) & 1
    tap_2_value = (seed >> tap_2_index) & 1
    x.append(seed)
    print(seed)
    return (((~(tap_1_value ^ tap_2_value))&1)<<19) + (seed>>1)

seed = 1

for i in range(20000):
    seed = lfsr(seed)
print(x)
plt.hist(x)  # density=False would make counts
plt.ylabel('Probability')
plt.xlabel('Data')

plt.show(block=False)
plt.pause(6)
plt.close('all')

y = norm.ppf([i/1049089 for i in x], loc=0, scale=3.35)
#mapping = {}
#for i in range(1,1049089,10):
#    mapping[int(norm.ppf([i/1049089], loc=0, scale=3.35)[0])] = i
#    print(i)

#print(mapping)
plt.hist(y, density=True)  # density=False would make counts
plt.ylabel('Probability')
plt.xlabel('Data')

plt.show(block=False)
plt.pause(6)
plt.close('all')
'''

def test_modular_inverse(a, n):
    state = 'INPUT'
    b2 = 0
    b1 = 1
    b = None

    while state != 'DONE':
        if state == 'INPUT':
            state = 'DIVIDE'
        if state == 'DIVIDE':
            b = b2-b1*(n//a)
            if n%a != 1:
                state = 'REINITIALIZE'
            else:
                state = 'DONE'
        if state == 'REINITIALIZE':
            n, a = a, n % a
            b2, b1 = b1, b
            state = 'DIVIDE'

    return b if b > 0 else n + b

print(test_modular_inverse(1323, 1346))