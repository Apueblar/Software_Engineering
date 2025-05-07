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

def taxi_fares(km, initial_Fare, price, meters_fare):
    price = initial_Fare * 100

    price += 25 * ((km * 1000) / meters_fare)

    return round(price / 100, 2)

if __name__ == '__main__':
    km = 1000
    initial_Fare = 4
    price = 0.25
    meters_fare = 140

    print(taxi_fares(km, initial_Fare, price, meters_fare))

