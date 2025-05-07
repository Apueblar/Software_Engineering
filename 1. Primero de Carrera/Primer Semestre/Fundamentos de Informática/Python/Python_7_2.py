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
import random
def password_generator(length, CAP, DIG, SYM, valid_SYM):
    password = ""
    chars_lower = "qwertyuioplkjhgfdsazxcvbnm"
    chars_upper = chars_lower.upper()
    digits = "0123456789"
    possible_char = chars_lower
    if CAP:
        possible_char += chars_upper
    if DIG:
        possible_char += digits
    if SYM:
        possible_char += valid_SYM

    for _ in range(length):
        password += random.choice(possible_char)

    return password

if __name__ == '__main__':
    print(password_generator(10, True, True, True, "?¿[]{}<>!¡"))
