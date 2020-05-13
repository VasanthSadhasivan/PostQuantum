import ntt_tools, efficient_ntt
n = 256
q = 1049089
xog = [i for i in range(n)]

x1 = xog.copy()
a = ntt_tools.find_params_and_transform(x1, q)
print("NTT Correct:",a[0])
print("Primitive Root:", a[1])
print("Working Modulo:", a[2])

x2 = xog.copy()
W = [(a[1]**i)%a[2] for i in range(n)]
transform = efficient_ntt.ntt(x2, W, q)
print("NTT Me:",transform)

iW = [ntt_tools.reciprocal(w, q) for w in W]
print("iNTT Me:", efficient_ntt.intt(transform, iW, q))
