#-------------------------------------------------------------------------------
# Name:        Álvaro Puebla Ruisánchez
# Purpose:
#
# Author:      uo299874
#
# Created:     08/11/2023 - 10:00
# Copyright:   (c) uo299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import random

def sette_e_mezzo():
    points = 0
    while points < 7.5:
        card = random.randint(1,10)
        if card < 7.5:
            points += card
        else:
            points += 0.5
    if points == 7.5:
        return 1
    else:
        return 0

if __name__ == '__main__':
    runs = 10000
    w = 0
    for _ in range(runs):
        w += sette_e_mezzo()
    w_prob = w/runs
    print(f"After {runs} runs, the winning probability at Sette e mezzo is {w_prob}.")