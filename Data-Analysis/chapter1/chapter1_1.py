# ============================================================================
# Author: Zhihao Cui
# Institute: School of Mathematics and Statistics
# Student ID: 20233002662
# ============================================================================
# For detailed output, please refer to res1_1.pdf
# ============================================================================

import math

# --- Data types ---
x = 4
print(x, type(x))          # integer

y = True
print(y, type(y))          # boolean

z = 3.7
print(z, type(z))          # float

s = 'This is a string'
print(s, type(s))          # string

# --- Arithmetic operations on integers ---
x = 4
x1 = x + 4                 # addition
x2 = x * 3                 # multiplication
x += 2                     # equivalent to x = x + 2
x3 = x
x *= 3                     # equivalent to x = x * 3
x4 = x
x5 = x % 4                 # modulo (remainder)

# --- Arithmetic operations on floats ---
z = 3.7
z1 = z - 2                 # subtraction
z2 = z / 3                 # division
z3 = z // 3                # integer division (floor)
z4 = z ** 2                # power (z squared)
z5 = z4 ** 0.5             # square root
z6 = pow(z, 2)             # built-in power function
z7 = round(z)              # rounding to nearest integer
z8 = int(z)                # type conversion float -> int

print(x, x1, x2, x3, x4, x5)
print(z, z1, z2, z3, z4)
print(z5, z6, z7, z8)

# --- Math module functions ---
x = 4
print(math.sqrt(x))        # square root
print(math.pow(x, 2))      # power (float result)
print(math.exp(x))         # exponential e^x
print(math.log(x, 2))      # logarithm base 2
print(math.fabs(-4))       # absolute value
print(math.factorial(x))   # factorial

z = 0.2
print(math.ceil(z))        # ceiling (smallest integer >= z)
print(math.floor(z))       # floor (largest integer <= z)
print(math.trunc(z))       # truncate (remove fractional part)

z = 3 * math.pi
print(math.sin(z))         # sine
print(math.tanh(z))        # hyperbolic tangent

x = math.nan               # Not a Number
print(math.isnan(x))       # check for NaN

x = math.inf               # positive infinity (use -math.inf for negative)
print(math.isinf(x))       # check for infinity

# --- Logical (Boolean) operations ---
y1 = True
y2 = False

print(y1 and y2)           # logical AND
print(y1 or y2)            # logical OR
print(y1 and not y2)       # NOT y2 then AND

# --- String operations ---
s1 = 'This'

print(s1[1:])              # slice from index 1 to end
print(len(s1))             # string length
print('Length of string is ' + str(len(s1)))  # concatenation with type conversion
print(s1.upper())          # convert to uppercase
print(s1.lower())          # convert to lowercase

s2 = 'This is a string'
words = s2.split(' ')      # split by space -> list of words
print(words[0])
print(s2.replace('a', 'another'))   # replace substring
print(s2.replace('is', 'at'))
print(s2.find('a'))        # first occurrence index (or -1)
print(s1 in s2)            # substring membership test

print(s1 == 'This')        # equality comparison
print(s1 < 'That')         # lexicographic comparison (ASCII order)
print(s2 + ' too')         # string concatenation with '+'
print(s1 + ' ' * 3)        # concatenate s1 with three spaces