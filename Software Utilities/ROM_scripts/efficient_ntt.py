import math

def mod_inverse(n, mod):
  if not (0 = n < mod):
    raise ValueError()
  x, y = mod, n
  a, b = 0, 1
  while y != 0:
    a, b = b, a - x // y * b
    x, y = y, x % y
  if x == 1:
    return a % mod
  else:
    raise ValueError("Reciprocal does not exist")

def barret_reduction(x, n):
  k = int(math.log2(n))
  r = int((1 << (2*k))/n)

  t = x - ((x * r) >> (2*k))*n

  if t < n:
    return int(t)

  return int(t - n)

def bitreverse(x):
  format_string = '{:'+str(int(math.log2(len(x)))).zfill(2)+'b}'
  x_new = [x[int(format_string.format(i)[::-1], 2)] for i in range(len(x))]
  return x_new

def ntt(x, W, q):
  n = len(x)
  x = bitreverse(x)
  for stage in range(int(math.log2(n))):
    k = 0

    for i in range(n):
      if (1<<stage) & i == 0:
        w = W[k]
        old_x_i = x[i]
        old_x_i_corr = x[i ^ (1 << stage)]
        x[i] = barret_reduction(old_x_i + barret_reduction(w*old_x_i_corr,q),q)

        x[i ^ (1 << stage)] = barret_reduction(old_x_i - barret_reduction(w*old_x_i_corr,q),q)
        k = barret_reduction((k + (n >> (stage + 1))),(n/2))
  return x

def intt(x, iW, q):
  n = len(x)
  transform = ntt(x, iW, q)
  return [barret_reduction(x*mod_inverse(n, q),q) for x in transform]

def main():
  x = [672,671,0,1,2,3,4,672]
  q = 673
  W = [(326**i)%q for i in range(8)]
  #print("W:", W)
  print(x)
  print(ntt(x, W, q))

  iW = [mod_inverse(w, q) for w in W]
  print(intt(ntt(x, W, q), iW, q)) 

if __name__ == '__main__':
  main()
