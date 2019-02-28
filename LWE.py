# Unfiform Random Number Generator
# Gaussian Random Number Generator
# Private Key Generator
# Public Key Generator
# Encryption
# Decryption

'''
Parameters: lower and upper bounds
Return: sample value from distribution
'''
#Vasanth
def u_rng(a, b):
	pass

'''
Parameters: lower and upper bounds
Return: sample value from distribution
'''
#Lahiru
def g_rng(a, b):
	pass

'''
Parameters: Number of elements in our vector, a n^2 < prime < 2n^2 
Return: vector representing our private key in z mod q
'''
#Anthony
def private_key_gen(n, q):
	pass

'''
Parameters: Number of Elements, prime, secret/private key
Return: vector representing our public key in z mod q
'''
#Vasanth
def public_key_gen(n, q, s_key):
	pass

'''
Parameters: Vector representing our message to encrypt
Return: Vector of two vectors containing cipher text
'''
#Lahiru
def encrypt(m):
	pass

'''
Parameters: Cipher Text, secret/private key, prime
Return: Original message vector m
'''
#Anthony
def decrypt(c, s_key, q):
	pass

