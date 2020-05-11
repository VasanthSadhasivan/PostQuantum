
import numpy as np
cimport numpy as np



 # n : the largest degree in the polynomial defined in the paper as R sub q
cdef int n = 64 

 # q : a sample prime that satisfies q = 1 mod(n)
cdef int q = 257
 
 # f : the irreducible polynomial we mod to produce ring R
f  = np.poly1d([1] + [0] * (n - 1) + [1])

 # g/a : the global polynomial that exists in ring R
g  = np.poly1d(np.fmod(np.random.normal(scale = 10, size = 2).astype(int) , q))

 # Asks for user input in the form of an integer. Created to test functionality
def sample_program(m):
	public_key, private_key = key_gen()
	encrypted_message = encrypt(m, public_key)
	decrypted_message = decrypt(encrypted_message, private_key)
 	#pretty_print(m, encrypted_message, decrypted_message) 

 # Generate key based on math described in paper
cdef key_gen():
	global n, f, q, g

	r1 = np.poly1d(np.fmod(np.random.normal(scale = 10, size = n - 1).astype(int) , 2))
	r2 = np.poly1d(np.fmod(np.random.normal(scale = 10, size = n - 1).astype(int) , 2))

	f  = np.poly1d([1] + [0] * (n - 1) + [1]) 

	p = np.poly1d(np.fmod(np.polydiv(np.poly1d(np.fmod(r1 - g * r2, q)) , f) [1], q))
	sk = r2
	return [p,sk] #[public_key, private_key]

 # Encrypt given message using public key as described in paper
cdef encrypt( m, public_key):
	global n, f, q, g

	p = public_key
	tmp = list('{0:032b}'.format(m))
	cdef int i
	#m = [int(i) for i in list('{0:032b}'.format(m))]
	m_list = []
	for i in range(len(tmp)):
		m_list.append(int(tmp[i]))
	tmp2 =[]
	for i in range(len(m_list)):
		if m_list[i]==1:
			tmp2.append((q-1/2))
		else:
			tmp2.append(0)
	# m_masked = np.poly1d([(q-1)/2 if i == 1 else 0 for i in m])
	m_masked = np.poly1d(tmp2)
	e1 = np.fmod(np.poly1d(np.random.normal(scale = 10, size = n - 1).astype(int)) , 2)
	e2 = np.fmod(np.poly1d(np.random.normal(scale = 10, size = n - 1).astype(int)) , 2)
	e3 = np.fmod(np.poly1d(np.random.normal(scale = 10, size = n - 1).astype(int)) , 2)
	# print(np.fft.fft(e1))
	# print(np.fft.fft(g))
	cdef np.ndarray c1 = np.fmod(np.array(np.polydiv(g  * e1 + e2, f) [1]) , q)
	cdef np.ndarray c2 = np.fmod(np.array(np.polydiv(p * e1 + e3 + m_masked, f) [1]) , q)
	c3 = np.poly1d(c1)
	c4 = np.poly1d(c2)
	return [c3, c4] #encrypted message

 # Decrypt encrypted message using private key as described in paper
cdef decrypt(encrypted_message, private_key):
	global n, f, q, g

	c1 = encrypted_message[0]
	c2 = encrypted_message[1]

	x = np.fmod(np.array(np.polydiv(c1 * private_key + c2, f) [1]) , q)
	x = np.poly1d(x)
	cdef int i 
	cdef x_array = np.array(x)
	cdef np.ndarray decrypted
	for i in range(len(x_array)):
		if abs(int(x_array[i])) > q//4:
			decrypted.append(1)
		else:
			decrypted.append(0)
	# decrypted = [1 if abs(int(i)) > q//4 else 0 for i in np.array(x)]
	return decrypted

 # Print the input message, encrypted and decrypted data
# def pretty_print(m, encrypted_message, decrypted_message):
#     decrypted_data = int("".join(map(str, decrypted_message)), 2)
#     encrypted_data = ":".join([str(int(i)) for i in np.array(encrypted_message[0])]) + ",\n" +  ":".join([str(int(i)) for i in np.array(encrypted_message[1])])
#     message_data = m 

#     print("[+] Message Data:\t ", message_data)
#     print("[+] Encrypted Data:\t ", encrypted_data)
#     print("[+] Decrypted Data:\t ", decrypted_data)

 # Run the sample program over again
# def main():
#     while True:
# 	    sample_program()


