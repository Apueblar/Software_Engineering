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

import Python_6 as pkg

m1 = pkg.read_integer("Tell me a number: ")
m2 = pkg.read_integer("Tell me a number: ")

M = pkg.biggest(m1,m2)
print(f"The biggest number is {M}")