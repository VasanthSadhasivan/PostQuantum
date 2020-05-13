import numpy as np
import re

 # n : the largest degree in the polynomial defined in the paper as R sub q
n = 64 

 # q : a sample prime that satisfies q = 1 mod(n)
q = 257

 # f : the irreducible polynomial we mod to produce ring R
f  = np.poly1d([1] + [0] * (n - 1) + [1])

 # g/a : the global polynomial that exists in ring R
g  = np.poly1d(np.fmod(np.random.normal(scale = 10, size = 2).astype(int) , q))

 # Asks for user input in the form of an integer. Created to test functionality
def sample_program():
	public_key, private_key = key_gen()

 	m = int(input("Integer to encrypt: "))

	encrypted_message = encrypt(m, public_key)

 	decrypted_message = decrypt(encrypted_message, private_key)
	print("Public Key: ", public_key)
	print("Private Key: ", private_key)
 	pretty_print(m, encrypted_message, decrypted_message) 

 # Generate key based on math described in paper
def key_gen():
	global n, f, q, g

 	r1 = np.poly1d(np.fmod(np.random.normal(scale = 10, size = n - 1).astype(int) , 2))
	r2 = np.poly1d(np.fmod(np.random.normal(scale = 10, size = n - 1).astype(int) , 2))

 	f  = np.poly1d([1] + [0] * (n - 1) + [1]) 

 	p = np.poly1d(np.fmod(np.polydiv(np.poly1d(np.fmod(r1 - g * r2, q)) , f) [1], q))
	sk = r2

 	return [p,sk] #[public_key, private_key]

 # Encrypt given message using public key as described in paper
def encrypt(m, public_key):
	global n, f, q, g

 	p = public_key

 	m = [int(i) for i in list('{0:032b}'.format(m))]
	m_masked = np.poly1d([(q-1)/2 if i == 1 else 0 for i in m])

 	e1 = np.fmod(np.poly1d(np.random.normal(scale = 10, size = n - 1).astype(int)) , 2)
	e2 = np.fmod(np.poly1d(np.random.normal(scale = 10, size = n - 1).astype(int)) , 2)
	e3 = np.fmod(np.poly1d(np.random.normal(scale = 10, size = n - 1).astype(int)) , 2)
	#print(np.fft.fft(e1))
	#print(np.fft.fft(g))
 	c1 = np.fmod(np.array(np.polydiv(g  * e1 + e2, f) [1]) , q)
	c2 = np.fmod(np.array(np.polydiv(p * e1 + e3 + m_masked, f) [1]) , q)
	c1 = np.poly1d(c1)
	c2 = np.poly1d(c2)

 	return [c1, c2] #encrypted message

 # Decrypt encrypted message using private key as described in paper
def decrypt(encrypted_message, private_key):
	global n, f, q, g

 	c1 = encrypted_message[0]
	c2 = encrypted_message[1]

 	x = np.fmod(np.array(np.polydiv(c1 * private_key + c2, f) [1]) , q)
	x = np.poly1d(x)
	decrypted = [1 if abs(int(i)) > q//4 else 0 for i in np.array(x)]
	return decrypted

 # Print the input message, encrypted and decrypted data
def pretty_print(m, encrypted_message, decrypted_message):
        decrypted_data = int("".join(map(str, decrypted_message)), 2)
        encrypted_data = ":".join([str(int(i)) for i in np.array(encrypted_message[0])]) + ",\n" +  ":".join([str(int(i)) for i in np.array(encrypted_message[1])])
        message_data = m 

        print("[+] Message Data:\t ", message_data)
        print("[+] Encrypted Data:\t ", encrypted_data)
        print("[+] Decrypted Data:\t ", decrypted_data)

 # Run the sample program over again
def main():
	while True:
		sample_program()

if __name__ == "__main__":
	main()
