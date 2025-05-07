#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      UO299874
#
# Created:     15/11/2023
# Copyright:   (c) UO299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

##Problem 1. Write the following functions:
##read_integer : the function receives a message that will be prompt to the user who needs
##to enter an integer number. Then, it returns the number given by the user.
##biggest : given two numbers, returns the biggest one.
##Then, write a main program, to ask the user two numbers and print out the biggest one.

def read_integer(message):
    '''
    This function returns an integer value requested
    to the user with a suitable message using standard
    input.

    Parameters:
        message - a message to include in the input function call
    Return:
        the requested integer
    Lateral Effects:
        None
    '''
    number = None
    while not isinstance(number, int):
        try:
            number = int(input(message))
        except ValueError:
            print("Please enter a number.")
    return number

def biggest(number1, number2):
    '''
    Given two numbers, returns the biggest.
    '''
    return max(number1,number2)

def is_leap_year(year):
    return ((year % 4 == 0 and year % 100 != 0) or year % 400 == 0)

def nutritional_status(weight, height):
    '''
    Returns a string containing a string depending on the BMI

    Parameters:
        Weight (in kg) and Height (in meters)

    >>> nutritional_status(100,5)
    "Underweight"

    '''
    BMI = weight / (height**2)
    if BMI < 18.5:
        return "Underweight"
    if BMI < 25:
        return "Normal"
    if BMI < 30:
        return "Overweight"
    return "Obese"

def distance_to_0_0(x,y):
    return (x**2 + y**2)**(1/2)

def is_perfect_number(number):
    suma = 0
    for i in range(1,number):
        if number % i == 0:
            suma += i
    return suma == number

if __name__ == '__main__':
    x = int(input("Tell me the x coor: "))
    y = int(input("Tell me the y coor: "))
    print(distance_to_0_0(x,y))
