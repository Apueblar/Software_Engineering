#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      uo299874
#
# Created:     04/10/2023
# Copyright:   (c) uo299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import math , random

def p1():
    base = 0
    while not isinstance(base, float) or (base <= 0):
        try:
            base = float(input("Tell me a number for the base of the triangle: "))
            if base <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    height = 0
    while not isinstance(height, float) or (height <= 0):
        try:
            height = float(input("Tell me a number for the height of the triangle: "))
            if height <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    area = (base * height)/2
    print("The area of a triangle with base {0} and height {1} is {2}.".format(base,height,area))

def p2():
    l1 = 0
    while not isinstance(l1, float) or (l1 <= 0):
        try:
            l1 = float(input("Tell me a cathetos of the triangle: "))
            if l1 <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    l2 = 0
    while not isinstance(l2, float) or (l2 <= 0):
        try:
            l2 = float(input("Tell me the other cathetos of the triangle: "))
            if l2 <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    hypotenuse = math.sqrt((l1 ** 2) + (l2 ** 2))
    print("The hypotenuse is {}".format(hypotenuse))

def p3():
    print("The quadratic formula is: ax^2 + bx + c")
    a = 0
    while not isinstance(a, float):
        try:
            a = float(input("Tell me a number for the value of (a): "))
        except ValueError:
            print("Please enter a valid number.")

    b = 0
    while not isinstance(b, float):
        try:
            b = float(input("Tell me a number for the value of (b): "))
        except ValueError:
            print("Please enter a valid number.")

    c = 0
    while not isinstance(c, float):
        try:
            c = float(input("Tell me a number for the value of (c): "))
        except ValueError:
            print("Please enter a valid number.")

    print(f"The quadratic formula that you wrote is: {a}x^2 + {b}x + {c}")

    discriminant = (b**2) - (4 * a * c)
    if discriminant < 0:
        print("The is no real solution.")
    elif discriminant == 0:
        sol = (-b)/(2*a)
        print(f"The double solution is {sol}")
    else:
        sol1 = ((-b) + math.sqrt(discriminant)) / (2 * a)
        sol2 = ((-b) - math.sqrt(discriminant)) / (2 * a)
        print(f"The solutions of the quadratic formula are {sol1} and {sol2}.")

def p4():
    user = 10
    while not isinstance(user, int) or (user < 0) or (user > 9):
        try:
            user = int(input("Can you guess my number? "))
            if (user < 0) or (user > 9):
                print("Write a number between 0 and 9.")
        except ValueError:
            print("Please enter a valid number.")
    guess = random.randint(0,9)
    result = user == guess
    print(f"Your guess is: {result}")

def p5():
    weight = 0
    while not isinstance(weight, float) or (weight <= 0):
        try:
            weight = float(input("Tell me your weight: "))
            if weight <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    height = 0
    while not isinstance(height, float) or (height <= 0):
        try:
            height = float(input("Tell me your height: "))
            if height <= 0:
                print("Write a positive number.")
        except ValueError:
            print("Please enter a valid number.")

    bmi = (weight) / (height ** 2)

    print(format("[0, 18.5)?", "<20"), bmi >= 0.0 and bmi < 18.5)
    print(format("[18.5, 25.0)?", "<20"), bmi >= 18.5 and bmi < 25.0)
    print(format("[25.0, 30.0)?", "<20"), bmi >= 25.0 and bmi < 30.0)
    print(format("[30.0, 50)?", "<20"), bmi >= 30.0 and bmi < 50.0)

def p6():
    name = input("Tell me the name of the student: ")

    m1 = 0
    while not isinstance(m1, float) or (m1 < 0) or (m1 > 10):
        try:
            m1 = float(input("Tell me the fist mark: [0,10] "))
            if (m1 < 0) or (m1 > 10):
                print("Write a positive mark.")
        except ValueError:
            print("Please enter a valid mark.")

    m2 = 0
    while not isinstance(m2, float) or (m2 < 0) or (m2 > 10):
        try:
            m2 = float(input("Tell me the second mark: [0,10] "))
            if (m2 < 0) or (m2 > 10):
                print("Write a positive mark.")
        except ValueError:
            print("Please enter a valid mark.")

    r = ((m1 + m2)/2)
    print(f"The average mark of {name} is {r:.2f}")
    print(f"Pass the subject: {r >= 5}")

def p7():
    distm = float(input("Tell me a distance in meters: "))
    distcm = distm * 100
    distin = int(distcm / 2.54)
    distfo = distin % 12
    distya = distfo % 3
    print(f"{distm} meters are {distya} yards, {distfo} feet and {distin // 12} inches.")
    # NO funcionaaaaaaa

if __name__ == '__main__':
    #p1()
    #p2()
    #p3()
    #p4()
    #p5()
    #p6()
    p7()








