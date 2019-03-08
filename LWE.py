import numpy

'''
Parameters: lower and upper bounds, size
Return: sample value from distribution
'''
#Vasanth
def u_rng(a, b, n):
	return  numpy.random.uniform(a, b, n).tolist()

'''
Parameters: lower and upper bounds, size
Return: sample value from distribution
'''
#Lahiru
def g_rng(a, b, n):
	return numpy.random.normal(a, b, n).tolist()

'''
Parameters: Number of elements in our vector, a n^2 < prime < 2n^2 
Return: vector representing our private key in z mod q
'''
#Anthony
def private_key_gen(n, q):
	S = numpy.array(u_rng(0, q - 1, n))	
	return S.tolist()

'''
Parameters: Number of Elements, prime, secret/private key
Return: vector representing our public key in z mod q
'''
#Vasanth
def public_key_gen(n, m, q, s_key):
	A = numpy.empty([m, n], dtype=int)

	for i in range(m):
		A[i] = numpy.array(u_rng(0, q - 1, n))

	E = numpy.array(g_rng(0, 2, m))
	
	pub_key = []

	for i in range(m):
		pub_key.append(numpy.inner(A[i], numpy.array(s_key)) / q + int(E[i]))
	return [A.tolist(), pub_key]

'''
Parameters: Message Bit
Return: Vector of two vectors containing cipher text
'''
#Lahiru
def encrypt(m, pub_key):
	i = len(pub_key)
	a = pub_key[0]
	b = pub_key[1]
	res = [numpy.array(a[0]), numpy.array(b[0])]

	for j in range(i - 1):
		res[0] += numpy.array(a[j + 1])
		res[1] += b[j + 1]
	res[1] += m / 2.0
	return res

'''
Parameters: Cipher Text, secret/private key, prime
Return: Original message vector m
'''
def decrypt(c, s_key, q):
	a = c[0]
	b = c[1]
	print(c, s_key, q)
	m = numpy.inner(a, s_key)*(-1)/q + b
	return m % 2 

def main():
	n = 3
	m = 3
	q = 11

	s_key = private_key_gen(n, q)
	pub_key = public_key_gen(n, m, q, s_key)
	
	while True:
		input = int(raw_input("Input Bit: "))

		c = encrypt(input, pub_key) 
		m = decrypt(c, s_key, q)
		print("Output Bit: " + str(m))

if __name__ == "__main__":
	main()
