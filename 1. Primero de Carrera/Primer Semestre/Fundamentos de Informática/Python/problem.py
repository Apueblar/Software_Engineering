import math

# Let be a cylindrical swimming pool. Its diameter is 10m and its depth is 4m.
# It is filled with water from a tap capable of giving a stream of 80 liters per minute.
# How many hours it takes to be filled?

# First, calculate the volume in liters

# The formula is: radio (in meters) **2 * PI * depth(in meters)
# And then, change to liters multiplying by 1000

volume = 5**2 * math.pi * 4 * 1000

# Second, calculate how many minutes it takes to be filled
# The formula is: the total volume of the swimming pool / stream

minutes = volume / 80

# Show the time in hours
print(round(minutes/60,2))