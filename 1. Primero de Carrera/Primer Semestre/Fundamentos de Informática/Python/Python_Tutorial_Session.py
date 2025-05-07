#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      UO299874
#
# Created:     01/12/2023
# Copyright:   (c) UO299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

def main():
    f = open("./Raw Data/rawdata_279.csv", "r")
    a = f.read()
    f.close()
    a.replace(";\n", "; \n")
    lines = a.split(" ; \n")
    del lines[0]
    index = []
    country = []
    area = []
    for line in lines:
        if line == "\n": break
        data = line.split(" ; ")
        index.append(data[0])
        country.append(data[1])
        area.append(data[2])
    print(index)
    print(country)
    print(area)

if __name__ == '__main__':
    main()
    # [<expression> for <element> in <iterable>]
##    numbers=["123\n","68.5\n","-4.1\n","9.9\n"]
##    numbers=[float(x) for x in numeros]
    # [<expressionA> for <elemento> in <iterable> if <booleanexpression>]
##    a = [1, -1, -2, -3, -4, -5, -6]
##    b =[a.pop(a.index(x)) for x in a[:] if x < 0]

