#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      UO299874
#
# Created:     18/10/2023
# Copyright:   (c) UO299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

def example():
    x = 0
    n = 16
    while n % 2 == 0:
        x = x + 1
        n = n / 2
    print(x)

def p3_1():
    max_num = None
    while not isinstance(max_num, int):
        try:
            max_num = int(input("Tell me a number: "))
        except ValueError:
            print("Please enter a valid number.")

    n = 1
    for i in range(max_num - 1):
        n *= i + 2
    print(n)

def p3_2():
    max_num = int(input("Tell me a number: "))
    n = 1
    while max_num > 1:
        n *= max_num
        max_num -= 1
    print(n)

def p8():
    s = 0
    for i in range(1,101):
        s += (i**2) + (1/i)
    print(s)

def p9():

    lower_limit,upper_limit = None,None

    while not isinstance(lower_limit, int) or (lower_limit <= 0):
        try:
            lower_limit = int(input("Tell me a number for the lower limit: "))
            if lower_limit <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    while not isinstance(upper_limit, int) or (upper_limit < lower_limit):
        try:
            upper_limit = int(input(f"Tell me a number for the upper limit (> {lower_limit}): "))
            if upper_limit < lower_limit:
                print("Upper limit must be greater or equal to lower limit.")
        except ValueError:
            print("Please enter a valid number.")

    s = 0
    for i in range(lower_limit,upper_limit + 1):
        s += (i**2) + (1/i)
    print(s)

def p10():
    s = 0
    for i in range(5,11):
        t = 1
        for j in range(1,11):
            t *= i**j
        s += (1/i) * t
    print(s)

def p11():
    a = 0
    while True:
        text = input("Tell me a letter: ")
        if len(text) == 1:
            if text.lowwer == "a":
                a += 1
            elif text == ".":
                break
        else:
            print("You can only add 1 letter.")
    print(a)

def p12():
    a,b = None,None
    while not isinstance(a, int) or (a < 0):
        try:
            a = int(input("Tell me a number for a: "))
            if a <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")
    while not isinstance(b, int) or (b < 0):
        try:
            b = int(input("Tell me a number for a: "))
            if b <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    s = 0
    for i in range(b):
        s += a
    print(s)

def p13():
    a,b = None,None
    while not isinstance(a, int) or (a < 0):
        try:
            a = int(input("Tell me a number for a: "))
            if a < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")
    while not isinstance(b, int) or (b <= 0):
        try:
            b = int(input("Tell me a number for a: "))
            if b <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    c = 0

    while a > b:
        a -= b
        c += 1
    print(f"The cociente es {c} y el resto es {a}")

def p16():
    number = None
    while not isinstance(number, int) or (number < 0):
        try:
            number = int(input("Tell me a number: "))
            if number < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    resultado = 0
    while number > 0:
        resultado = resultado * 10 + (number % 10)
        number //=  10

    print(resultado)

def p17():
    number = None
    while not isinstance(number, int) or (number < 0):
        try:
            number = int(input("Tell me a number: "))
            if number < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")
    figures = 0
    while number > 0:
        number //= 10
        figures += 1
    print(figures)

def p18():
    number = None
    while not isinstance(number, int) or (number < 0):
        try:
            number = int(input("Tell me a number: "))
            if number < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    divisor = 1
    while number >= divisor:
        if number % divisor == 0:
            print(divisor, end = " ")
        divisor += 1
    print()

def p19():
    number = None
    while not isinstance(number, int) or (number < 0):
        try:
            number = int(input("Tell me a number: "))
            if number < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    suma = 0
    divisor = 1
    while number - 1 >= divisor:
        if number % divisor == 0:
            print(divisor, end = " ")
            suma += divisor
        divisor += 1
    print(suma == number)

def p20():
    n = 1
    while n < 1000:
        suma = 0
        aux = n
        while aux <= 0:
            d = aux % 10
            aux //= 10
            suma += d ** 3
        if suma == n:
            print(n)
        n += 1

def p23():
    number = None
    while not isinstance(number, int) or (number < 0):
        try:
            number = int(input("Tell me a number: "))
            if number < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    for i in range(number):
        print("*"*number)

def p24():
    n = None
    while not isinstance(n, int) or (n < 0):
        try:
            n = int(input("Tell me a number: "))
            if n < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    m = None
    while not isinstance(m, int) or (m < 0):
        try:
            m = int(input("Tell me a number: "))
            if m < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    for i in range(n):
        print("*"*m)

def p24_1():
    number = None
    while not isinstance(number, int) or (number < 0):
        try:
            number = int(input("Tell me a number: "))
            if number < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    for i in range(number):
        print("*"*(i+1))

def ptree():
    n = None
    while not isinstance(n, int) or (n < 0):
        try:
            n = int(input("Tell me a number: "))
            if n < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    h = None
    while not isinstance(h, int) or (h < 0):
        try:
            h = int(input("Tell me a number: "))
            if h < 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    for i in range((n+1) + h):
        if i < n + 1:
            for j in range (2*n + 1):
                    if ((i+j > 3) and (i+j <= 4)) or (i == n) or (j-i == 4):
                        ch = "*"
                    else:
                        ch = " "
                    print(ch, end = "")
            print()
        else:
            print(" " * n + "*")

if __name__ == '__main__':
    #example()
    #p3_1()
    #p3_2()
    #p8()
    #p9()
    #p10()
    #p11()
    #p12()
    #p13()
    #p16()
    #p17()
    #p18()
    #p19()
    #p20()
    #p23()
    #p24()
    #p24_1()
    ptree()