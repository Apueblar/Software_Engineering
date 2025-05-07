#-------------------------------------------------------------------------------
# Name:        Python_1
# Purpose:
#
# Author:      uo299874
#
# Created:     27/09/2023
# Copyright:   (c) uo299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import math

def main():
    t = (2**15,3**12,5**10)
    print(max(t)) # max() pasa el mayor valor
    print(bin(ord("a"))) # ord() pasa de str a int
    print(bin(ord("A"))) # bin() transforms int to binary
    print(hex(0b1100001)) # hex() transforms binary to int
    print(chr(81)) # chr() pasa de int a str
    txt = "Hola a todos, {0} Álvaro {1} y me gusta esta {2}. Tengo {3} años"
    print(txt.format("soy", "Puebla", "materia",17))

    print("3.4 rounded is {0} also {1} and also {2}".format(round(3.4),round(3.4,2),round(3.4,5)))
    print(1/2 == 1//2)
    a = 3
    b = a + 5


def ex4():
    print(500%7)
    print("*" * 80)
    print("%.5f" % (math.sqrt(3)))
    n = 5
    print(2**(1/n))

def ex5():
    temperature = float(input("Tell  me the temperature in Fº: "))
    temc = (temperature - 32) * 5 / 9
    temf = temc * 9 / 5 + 32
    print("%f Fº, %f Cº, %f Fº" % (temperature, temc, temf))

def ex6():
    a = 9.8
    t = 30
    v0 = 20
    vf = v0 + a * t
    print(vf)

def ex7():
    names,height = [],[]
    for i in range(3):
        n = input("Tell me the name of a friend: ")
        h = float(input("Tell me the height of %s: " % (n)))
        names.append(n)
        height.append(h)
    ma = height.index(max(height))
    print("The tallest is {0} with {1:.1f}".format(names[ma],height[ma]))
    mi = height.index(min(height))
    print("The smallest is {0} with {1:.1f}".format(names[mi],height[mi]))

if __name__ == '__main__':
    #main()
    #ex4()
    #ex5()
    #ex6()
    ex7()
