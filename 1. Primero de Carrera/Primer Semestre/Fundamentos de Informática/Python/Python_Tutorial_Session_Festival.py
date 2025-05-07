#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      UO299874
#
# Created:     25/10/2023
# Copyright:   (c) UO299874 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import random

def dragons_realm(k):
    print("You are in the Dragons Realm Game.")
    # K es el número de juegos
    win, draw,lose = 0,0,0
    while k > 0:
        r_number = random.random()

        u_number = None
        while not isinstance(u_number, float) or (u_number < 0) or (u_number > 1):
            try:
                u_number = float(input("Tell me a number between 0 and 1: "))
                if (u_number < 0) or (u_number > 1):
                    print("Write a number between 0 and 1.")
            except ValueError:
                print("Please enter a valid number.")

        print(f"Your number was {u_number} and the dragon has chosen {r_number}")

        if abs(r_number - u_number) <= 0.125:
            print("You won this fight.")
            win += 1
        elif abs(r_number - u_number) <= 0.2:
            print("You draw this fight.")
            draw += 1
        else:
            print("You lost this fight.")
            lose += 1
        print()
        k -= 1

    if (win + draw) > (win + draw + lose) / 2:
        print("You pass the game")
        return True
    else:
        return False

def question_of_letters():
    print("You are in the Question of Letters Game.")
    rw = 0
    rl = 0

    while rw != 3 and rl != 3:
        letter = input("Enter a letter: ").lower()
        while len(letter) != 1:
            letter = input("Enter a letter: ").lower()

        l1 = random.randint(97,122)
        l2 = random.randint(97,122)

        print(chr(l1) + chr(l2))

        u = ord(letter)
        if l1 < l2: # l1 va a ser siempre el mayor
            l1,l2 = l2,l1

        if l2 < u and u < l1:
            rl = 0
            rw += 1
            print("You won.")
            print(f"Your streak of wins is {rw}.")
        else:
            rw = 0
            rl += 1
            print("You lost.")
            print(f"Your streak of loses is {rl}.")

    if rw == 3:
        print("You pass the game")
        return True
    else:
        return False

def rock_paper_scissors(z):
    win,lose = 0,0
    for _ in range(z):
        u = 0
        while u != 1 and u != 2 and u != 3:
            print("You are in the Rock Paper Scrissors Game:")
            u = input("Enter rock / paper / scissors: ").lower()

            if u == "rock":
                u = 1
            elif u == "paper":
                u = 2
            elif u == "scissors":
                u = 3

        c = random.randint(1,3)

        if c == u:
            print("Draw.")
        elif (u + 3 - c) % 3 == 1:
            print("You won")
            win += 1
        else:
            print("You lost")
            lose += 1

    if win > lose:
        return True
    else:
        return False

def dungeons():
    print("You are in the Dungeons:")

    input("Role the dice (Enter)")
    d1 = random.randint(1,6)
    print(f"The result was {d1}.")

    input("Role the dice (Enter)")
    d2 = random.randint(1,6)
    print(f"The result was {d2}.")

    if (d1+d2) % 2 == 0:
        return True
    else:
        return False

def victory():
    print("YOU WON")

def lose():
    print("YOU LOST")

def game():
    while True:
        if dragons_realm(5):
            if question_of_letters():
                if rock_paper_scissors(5):
                    victory()
                    break
                else:
                    if dungeons():
                        game()
                    else:
                        lose()
                        break
            else:
                if dungeons():
                    game()
                else:
                    lose()
                    break
        else:
            lose()
            break



if __name__ == '__main__':
    game()
