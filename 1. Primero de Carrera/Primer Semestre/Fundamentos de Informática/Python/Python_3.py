#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      uo299874
#
# Created:     11/10/2023
# Copyright:   (c) uo299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import random

def p2():
    int1, int2, int3 = None,None,None
    while not isinstance(int1, int):
        try:
            int1 = int(input("Say me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(int2, int):
        try:
            int2 = int(input("Say me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(int3, int):
        try:
            int3 = int(input("Say me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    if int1 <= int2 <= int3:
        print("They are in ascending order.")
    else:
        print("They are not in ascending order.")

def p3():
    a,b,c,d,e = None,None,None,None,None
    while not isinstance(a, int):
        try:
            a = int(input("Say me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(b, int):
        try:
            b = int(input("Say me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(c, int):
        try:
            c = int(input("Say me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(d, int):
        try:
            d = int(input("Say me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(e, int):
        try:
            e = int(input("Say me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    if a >= max(b,c,d,e):
        print(f"The first value was the highest: {a}")
    elif b >= max(c,d,e):
        print(f"The second value was the highest: {b}")
    elif c >= max(d,e):
        print(f"The third value was the highest: {c}")
    elif d >= e:
        print(f"The fourth value was the highest: {d}")
    else:
        print(f"The fifth value was the highest: {e}")

def p4():
    # ax +b = 0 -> x = -b/a
    a,b = None,None
    while not isinstance(a, float) or a == 0:
        try:
            a = float(input("Tell me the value of a (ax+b=0): "))
            if a == 0:
                print("(a) can't be 0.")
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(b, float):
        try:
            b = float(input("Tell me the value of b (ax+b=0): "))
        except ValueError:
            print("Please enter a valid number.")

    print(f"The solution to a = {a} and b = {b} in the ecuation ax+b = 0 is {-b/a}")

def p5():
    a= None
    while not isinstance(a, int):
        try:
            a = int(input("Tell me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    print("a. Calculate the square of the number/nb. Calculate the cube of the number/nc. Calculate 2 times the number/n")
    b = input("Tell me your option: ")
    if b.lower() == "a":
        print(f"The square of {a} is {a**2}")
    elif b.lower() == "b":
        print(f"The cube of {a} is {a**3}")
    elif b.lower() == "c":
        print(f"2 times {a} is {2*a}")

def p6():
    a,b,c,d = 101,101,101,101
    while not isinstance(a, int) or not (0 <= a <= 100):
        try:
            a = int(input("Tell me a number [0,100]: "))
            if (0 <= a <= 100):
                print("Tell a number in the range [0,100]: ")
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(b, int) or not (0 <= b <= 100):
        try:
            b = int(input("Tell me a number [0,100]: "))
            if (0 <= b <= 100):
                print("Tell a number in the range [0,100]: ")
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(c, int) or not (0 <= c <= 100):
        try:
            c = int(input("Tell me a number [0,100]: "))
            if (0 <= c <= 100):
                print("Tell a number in the range [0,100]: ")
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(d, int) or not (0 <= d <= 100):
        try:
            d = int(input("Tell me a number [0,100]: "))
            if (0 <= d <= 100):
                print("Tell a number in the range [0,100]: ")
        except ValueError:
            print("Please enter a valid number.")

    e = (a + b + c + d) / 4

    if e < 60:
        m = "E"
    elif e < 70:
        m = "D"
    elif e < 80:
        m = "C"
    elif e < 90:
        m = "B"
    else:
        m = "A"
    print(f"The final mark is {m} with an average mark of {e}")

def p7():
    anual_income = int(input("Tell me the anual income: "))
    if anual_income < 12000:
        print("You don't pay anything")
    elif anual_income <= 35000:
        pay_anual = (anual_income - 12000) * 0.2
        pay_monthly = pay_anual / 12
        print(f"You pay monthly: {pay_monthly} with a rate of {anual_income / pay_anual}")
    elif anual_income <= 50000:
        pay_anual = 13000 * 0.2 + (anual_income - 35000) * 0.3
        pay_monthly = pay_anual / 12
        print(f"You pay monthly: {pay_monthly} with a rate of {anual_income / pay_anual}")

def p13():
    user = float(input("Tell me a number [0,1]: "))

    dragon = random.random()

    if 0 <= user <= 1:
        if dragon < user:
            print("You died.")
        else:
            print("You survived.")
    else:
        print("You need to write a number between 0 and 1.")

def p14():
    a = int(input("Tell me 0,1,2: "))
    b = int(input("Tell me 0,1,2: "))
    if (0<= a <= 2) and (0<= b <= 2):
        if a == b: print("Empate.")
        elif a == 0:
            if b == 1: print("Second player wins.")
            else: print("First player wins.")
        elif a == 1:
            if b == 2: print("Second player wins.")
            else: print("First player wins.")
        else:
            if b == 0: print("Second player wins.")
            else: print("First player wins.")


if __name__ == '__main__':
    #p2()
    #p3()
    #p4()
    #p5()
    #p6()
    #p7()
    #p13()
    p14()
