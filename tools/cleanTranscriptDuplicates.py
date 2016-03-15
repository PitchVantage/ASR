#for some reason, transcripts file has four of everything.  This script cleans out duplicates.

f = open("/home/mcapizzi/Desktop/transcripts", "rb")

#list to house cleaned lines
clean = []

#variable to house current line
current_line = ""

for line in f:
	if line != current_line:
		current_line = line
		clean.append(line)

f.close()

f = open("/home/mcapizzi/Desktop/transcripts_clean", "wb")

for line in clean:
	f.write(line)

f.close()


