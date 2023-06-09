import matplotlib.pyplot as plt

# Data for OR tools - airland1
x_a = [0.072, 0.062, 0.052, 0.036, 0.022, 0.013]
y_a = [700, 1320, 1960, 10590, 11520, 15280]

# Data for Sicstus Prolog - airland1
x_b = [0.28, 0.206, 0.189, 0.16, 0.145, 0.119, 0.101, 0.068, 0.044]
y_b = [700, 1180, 1270, 1610, 2360, 2990, 3260, 3530, 3650]

plt.plot(x_a, y_a, color="#f1e1ca", label='OR Tools')
plt.plot(x_b, y_b, color="#4d8495", label='Sicstus Prolog')

plt.xlabel('Time (s)')
plt.ylabel('Solution')
plt.title('OR Tools vs Sicstus Prolog')

plt.legend()

plt.show()


# Data for OR Tools - airland2
x_b = [0.364, 0.323, 0.284, 0.242, 0.188, 0.145, 0.13, 0.079, 0.0395, 0.0112]
y_b = [1480, 1500, 1520, 1570, 1690, 1720, 1880, 35230, 64590, 70230]

# Data for OR Tools - airland3
x_c = [0.097, 0.084, 0.064, 0.062, 0.042, 0.038, 0.03]
y_c = [820, 7040, 6840, 8980, 44290, 71710, 74020]

# Data for OR Tools - airland8
x_d = [0.331, 0.310, 0.279, 0.246, 0.216, 0.188, 0.156, 0.118]
y_d = [1950, 1975, 16950, 15835, 16930, 16465, 16955, 156085]

# Plotting the data
plt.plot(x_a, y_a, color="#f1e1ca", label='OR Tools - Airland 1')
plt.plot(x_b, y_b, color="#4d8495", label='OR Tools - Airland 2')
plt.plot(x_c, y_c, color="#c060a1", label='OR Tools - Airland 3')
plt.plot(x_d, y_d, color="#82c0c9", label='OR Tools - Airland 8')

plt.xlabel('Time (s)')
plt.ylabel('Solution')
plt.title('OR Tools')

plt.legend()

plt.show()

