#-------------------------------------------------------------------------------
# Name:        Exercise 3
# Purpose:
#
# Author:      uo299874
#
# Created:     12/01/2024
# Copyright:   (c) uo299874 2024
# Licence:     <your licence>
#-------------------------------------------------------------------------------

link = "maillog.txt"
out = "mail_report_domains.txt"

f = open(link, "r")
line = f.readline()
domains = []
while line != "":

    line = line.replace("  ", " ")
    line = line.split(' ')
    line4 = line[4]
    try:
        line4 = line4.split('[')
        if line4[0] == "postfix/relay/smtp" and line[11] == "status=sent":
            line6 = line[6]
            line6 = line6.rstrip(">,")
            line6 = line6.lstrip("to=<")
            email = line6.split("@")
            domain = email[1].lower()
            contains = 0
            for d in domains:
                if d == domain:
                    contains = 1
                    break
            if contains == 0:
                domains.append(domain)

    except IndexError:
        continue
    finally:
        line = f.readline()

f.close()
g = open(out, "w")
print("filtered domains:\n")
for dom in domains:
    print(dom)
    g.write(dom + "\n")

print(f"\ntotal amount: {len(domains)}")
g.close()
