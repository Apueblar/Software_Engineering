#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      UO299874
#
# Created:     13/12/2023
# Copyright:   (c) UO299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

def p0():
    f = open("Python_8.py", "r")
    char = f.read(1)
    while char != "":
        print(char, end = "")
        char = f.read(1)
    f.close()

def p1():
    path = "coefficients.txt" # input("Write the name of the file: ")
    coef = []
    ans = 0
    while ans != "No":
        try:
            ans = input("Tell me a coeficient: ")
            ans = int(ans)
            coef.append(str(ans))
        except ValueError:
            if ans != "No":
                print("Please enter a valid number.")
    coef = " ".join(coef)
    f = open(path, "w")
    f.write(coef)
    f.flush()
    f.close()

def p2():
    path = "xvalues.txt" # input("Write the name of the file: ")
    ans = 0
    f = open(path, "w")
    while ans != "No":
        try:
            ans = input("Tell me a value of x: ")
            ans = int(ans)
            f.write(str(ans) + "\n")
            f.flush()
        except ValueError:
            if ans != "No":
                print("Please enter a valid number.")
    f.close()

def p3():
    path_coef = "coefficients.txt" # input("Write the name of the file: ")
    path_xvalu = "xvalues.txt" # input("Write the name of the file: ")

    f = open(path_coef, "r")
    coeficients = f.read()
    f.close()
    coefs = coeficients.split(" ")

    f = open(path_xvalu, "r")
    x_value = f.readline()
    while x_value != "":
        x_value = x_value.rstrip("\n")
        print(f"x = {x_value} -> ", end = "")
        pol_sol = 0

        sum_the_values = [int(coefs[i]) * (int(x_value) ** i) for i in range(len(coefs))]
        for i in sum_the_values:
            pol_sol += i
        print(pol_sol)

        x_value = f.readline()

    f.close()


if __name__ == '__main__':
    #p0()
    #p1()
    #p2()
    p3()
