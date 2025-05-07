#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      UO299874
#
# Created:     29/11/2023
# Copyright:   (c) UO299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import random

def sum_list(list1):
    suma = 0
    for i in list1:
        suma += i
    return suma

def biggest_index(list1):
    '''Devuelve el índice del mayor número en la lista.

    >>> biggest_index([90,243,543,23,456])
    2
    '''
    return list1.index(max(list1))

def write_zeros(list2):
    for i in range(len(list2)):
        if list2[i] < 0: list2[i] = 0

def sum_powers(list1, n):
    suma = 0
    for i in list1:
        suma += i**n
    return suma

def rotate_left(list2, n = 1):
    list1 = list2[:]
    for _ in range(n):
        a = list1[0]
        for i in range(1,len(list1)):
            list1[i-1] = list1[i]
        list1[-1] = a
    return list1

def first_last6(list1):
    if list1[0] == 6: return True
    if list1[-1] == 6: return True
    return False

def reverse(list1):
    list2 = []
    for i in list1[::-1]:
        list2.append(i)
    return list2

def count_evens(list1):
##    even = 0
##    for i in list1:
##        if i % 2 == 0:
##            even += 1
##    return even
    return sum((1 for i in list1 if i % 2 == 0))

def big_diff(list1):
    maximum = max(list1)
    minimum = min(list1)
    return maximum - minimum

def centered_average(list1):
    maximum = max(list1)
    minimum = min(list1)
    list2 = list1[:]
    list2.remove(maximum)
    list2.remove(minimum)
    suma = 0
    for i in list2:
        suma += i
    return suma / len(list2)

def popular_name(list1):
    pos = 0
    for i in range(0, len(list1), 2):
        if list1[pos + 1] < list1[i + 1]:
            pos = i
    return list1[pos]

def vector(n):
    vector = []
    for _ in range(n):
        vector.append(random.randint(1,100))
    return vector

def print_matrix(list1, m):
    for i in range(len(list1)):
        if (i + 1) % m == 0: sep = '\n'
        else: sep = ' '
        print(list1[i], end=sep)
    print()

def substitution(text, abcdario):
    cipher_text = []
    for i in text.lower():
        num = ord(i) - 97
        cipher_text.append(abcdario[num])
    a = "".join(cipher_text)
    print(a)
    return a

if __name__ == '__main__':
    list1 = [90,243,543,23,456]
    print(sum_list(list1))

    print(biggest_index(list1))

    list2 = [ 3, -4, 5, 7, -1, 2]
    write_zeros(list2)
    print(list2)

    list2 = [5, 11, 9]
    rotate_left(list2, 1)
    print(list2)

    print(popular_name(['ana', 223, 'laura', 204, 'elena', 175]))
    print(popular_name(['laura', 204, 'ana', 223, 'elena', 175]))
    print(popular_name(['elena', 175, 'laura', 204, 'ana', 223]))

    print_matrix([1,2,3,4,5,6,7,8,9,8,7,6,5,4,3,2,1] , 5)

    substitution("abc","cdbafgehmnlijtsrqpozyxwv")