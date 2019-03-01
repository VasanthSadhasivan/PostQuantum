import numpy

'''
Parameters: lower and upper bounds, size
Return: sample value from distribution
'''
#Vasanth
def u_rng(a, b, n):
	list =  numpy.random.uniform(a, b, n).tolist()
	return [x for x in list]

'''
Parameters: lower and upper bounds, size
Return: sample value from distribution
'''
#Lahiru
def g_rng(a, b, n):
	mean = b-a
	return numpy.random.normal(mean,3,None)

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
	A = numpy.array(u_rng(0, q, n)); 
	E = numpy.array(g_rng(0, q, n));
	
	pub_key = numpy.inner(A, numpy.array(s_key)) / q + E

	return pub_key.tolist()

'''
Parameters: Vector representing our message to encrypt
Return: Vector of two vectors containing cipher text
'''
#Lahiru
def encrypt(m):
	for x in range(m.size()):
		S[1][x] = (m[x]/2) + (S[1][x])
	return S

'''
Parameters: Cipher Text, secret/private key, prime
Return: Original message vector m
'''
def decrypt(c, s_key, q):
	a = c[0]
	b = c[1]

	m = numpy.inner(a, s_key)*(-1)/q + b
	m = m.tolist()
	m = [x % q for x in m]
	m = [x * 2 for x in m] 
	
	return [0 if x < 1 else 1 for x in m]

