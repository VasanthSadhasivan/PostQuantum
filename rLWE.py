import numpy
import math

n = 256
q = 7681
std_dev = 11.31/math.sqrt(2*math.pi)

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
def g_rng():
        global n, std_dev
	return [0] + numpy.random.normal(0, std_dev, n-1).tolist()

'''
Parameters: Number of Elements, prime, secret/private key
Return: vector representing our public key in z mod q
'''
def key_gen(n, a, q):
	r1 = g_rng()
	r2 = g_rng()
	r1_ntt = numpy.fft.fft(r1)
	r2_ntt = numpy.fft.fft(r2)
	p1_ntt = r1_ntt - numpy.convolve(a, r2)
	return r2_ntt, (a, p1_ntt)


'''
Parameters: Message Bit
Return: Vector of two vectors containing cipher text
'''
#Lahiru
def encrypt(m, a_ntt, p_ntt):
	e1 = g_rng()
	e2 = g_rng()
	e3 = g_rng()
	e1_ntt = numpy.fft.fft(e1)
	e2_ntt = numpy.fft.fft(e2)
	
	return numpy.convolve(a_ntt, e1_ntt) + e2_ntt, numpy.convolve(p_ntt, e1_ntt) + numpy.fft.fft(e3 + m) 
	
	
'''
Parameters: Cipher Text, secret/private key, prime
Return: Original message vector m
'''
def decrypt(c1_ntt, c2_ntt, r2_ntt):
	return numpy.fft.ifft(numpy.convolve(c1_ntt,r2_ntt) + c2_ntt)
	
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
