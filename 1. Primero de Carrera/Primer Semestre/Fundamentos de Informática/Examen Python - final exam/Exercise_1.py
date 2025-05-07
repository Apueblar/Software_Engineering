#-------------------------------------------------------------------------------
# Name:        Exercise 1
# Purpose:
#
# Author:      uo299874
#
# Created:     12/01/2024
# Copyright:   (c) uo299874 2024
# Licence:     <your licence>
#-------------------------------------------------------------------------------

cont = "y"

while cont == "y":
    number = int(input("Input the cell phone coverage level from 0 to 5: "))
    if number == 0:
        print("@@")
    else:
        for i in range(number):
            print(f"{' ' * (number - (1 + i)) + '#' * (i + 1)} {number - i}")
    cont = input("Continue? [y/n]: ")
print("Simulation done")