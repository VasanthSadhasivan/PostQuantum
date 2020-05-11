import timeit
import rLWE

number_iterations = 100
rLWE_py = timeit.timeit(
    "rLWE.sample_program(10)", setup="import rLWE", number=number_iterations
)

# rLWE_cy = timeit.timeit(
#     "rLWE_cython.sample_program(10)",
#     setup="import rLWE_cython",
#     number=number_iterations,
# )


print("It takes {} seconds to complete {} runs".format(rLWE_py, number_iterations))
print(
    "It takes {} seconds to run one encode and decode".format(
        rLWE_py / number_iterations
    )
)
d_m = rLWE.sample_program(10)
m = ""
for i in range(len(d_m)):
    m += str(d_m[i])
m = int(m, 2)
print(m)
# print("It takes {} seconds to complete {} runs".format(rLWE_cy, number_iterations))
# print(
#     "It takes {} seconds to run one encode and decode".format(
#         rLWE_cy / number_iterations
#     )
# )

# print("Cython is {}x faster".format(rLWE_cy / rLWE_py))
