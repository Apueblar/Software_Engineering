#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      uo299874
#
# Created:     08/11/2023
# Copyright:   (c) uo299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

def main():
    NR = 8
    NC = 8
    for i in range(NR):
        for j in range(NC):
            if (i+j)%2 == 0: char = "#"
            else: char = " "
            print(char,end = "")
        print()

if __name__ == '__main__':
    main()
