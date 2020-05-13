#!/usr/bin/python

def modInverse(a, m) : 
    a = a % m; 
    for x in range(1, m) : 
        if ((a * x) % m == 1) : 
            return x 
    return 1

def dft(data):
        #data length is n= 8
        n = 8
        M = 256
        k = 32
	N = k*n + 1 #k = 257
	g = 3
	w = (g ** k) % N

	output = []

	for i in range(len(data)):
		output.append(0)
	
		for j in range(len(data)):
			output[i] = (output[i] + data[j] * (w ** (1 * j * i))) % N
	
	return output

def idft(data):
        #data length is n= 8
        n = 8
        M = 256
        k = 32
	g = 3
        N = k*n + 1 #k=11 #k = 257
        w = (g ** k) % N
	w = modInverse(w, N)

        output = []

        for i in range(len(data)):
                output.append(0)
        
	        for j in range(len(data)):
                        output[i] = (output[i] + data[j] * (w ** (1 * j * i))) % N
		print(output[i])
		output[i] = (modInverse(n, N) * output[i]) % N
      
	return output

def main():
	data = [1,2,3,4,5,6,7,8]
	transform = dft(data)
	orig = idft(transform)

	print(data)
	print(transform)
	print(orig)

if __name__ == "__main__":
	main()
