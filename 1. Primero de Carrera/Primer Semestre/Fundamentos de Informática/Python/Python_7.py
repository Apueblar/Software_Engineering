#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      UO299874
#
# Created:     22/11/2023
# Copyright:   (c) UO299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

def isprime(number):
    i = 2
    while number > i ** 2 - 1:
        if number % i == 0:
            return False
        i += 1
    print(f"{number} is a prime number.")
    return True


if __name__ == '__main__':
    x = int(input("Give me a number: "))
    while x >= 2:
        isprime(x)
        x = int(input("Give me a number: "))