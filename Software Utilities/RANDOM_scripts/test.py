import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import norm

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