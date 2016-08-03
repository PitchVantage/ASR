import sys

# This script merges two phones lists together
# NOTE:  They **must both** be sorted alphabetically already!


# sys.argv[1] = full path to location for merged output phones list
# sys.argv[2] = phones list one
# sys.argv[3] = phones list two

# open file for outputting new phones list
fOut = open(sys.argv[1], "wb")

# read in phones list one into a list
f_1 = open(sys.argv[2], "rb")
phones_1 = []

for line in f_1:
    phones_1.append(line.rstrip())

f_1.close()

# read in phones list two into a list
f_2 = open(sys.argv[3], "rb")
phones_2 = []

for line in f_2:
    phones_2.append(line.rstrip())

f_2.close()

# merge lists
merged = sorted(list(set(phones_1 + phones_2)))

# write to file
for phone in merged:
    fOut.write(phone + "\n")

fOut.close()
