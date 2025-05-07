#-------------------------------------------------------------------------------
# Name:        Exercise 2
# Purpose:
#
# Author:      uo299874
#
# Created:     12/01/2024
# Copyright:   (c) uo299874 2024
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import random

def select_cards(characters, weapons, rooms):
    dealer = []
    dealer.append(random.choice(characters))

    dealer.append(random.choice(weapons))

    dealer.append(random.choice(rooms))

    return dealer

def create_deck(characters, weapons, rooms, dealer):
    dealer_character = dealer[0]
    dealer_weapon = dealer[1]
    dealer_room = dealer[2]

    return_characters = characters[:]
    return_weapons = weapons[:]
    return_rooms = rooms[:]

    return_characters.remove(dealer_character)
    return_weapons.remove(dealer_weapon)
    return_rooms.remove(dealer_room)

    return return_characters[:] + return_weapons[:] + return_rooms[:]

characters = ['Miss Scarlett', 'Coronel Mustard', 'Mr. White', 'Rev. Green', 'Mrs. Peacock', 'Prof. Plum']
weapons = ['Candelstick', 'Dagger', 'Lead piping', 'Revolver', 'Rope', 'Spanner']
rooms = ['Kitchen', 'Dining Room', 'Lounge', 'Hall', 'Study', 'Library', 'Billiard Room', 'Conservatory', 'Ballroom']

for _ in range(10):
    play_to_be_guessed = select_cards(characters, weapons, rooms)
    deck = create_deck(characters, weapons, rooms, play_to_be_guessed)

    print(play_to_be_guessed)
    print(deck)
    print(len(deck))