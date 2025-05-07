#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      UO299874
#
# Created:     22/11/2023
# Copyright:   (c) UO299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

list1 = [5, 8, 10]
list2 = [3, 2, 9, 12, 4]

print(len(list1))
print(len(list2))

list_con = list1 + list2

print(len(list_con))

i = max(list1)
j = max(list2)
k = max(i,j)
print(k)

i = max(list_con)
print(i)

list1[0] + list2[0]
print(list1[0] + list2[0])

print(list1[-1] + list2[-1])

index = list1.index(8)
list1[index] = 0
print(list1)

list3 = list2
print(list3)

list3[0] = 7
print(list2)

for i in list1:
    print(i)

for i in list2[::-1]:
    print(i)

