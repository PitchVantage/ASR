import sys

#takes full transcript list and makes individual files for testing goVivace
#TODO handle special characters

# argv[1] = transcript file
# argv[2] = location for .gold files		**ending in /

f = open(sys.argv[1], "rb")

for line in f:
	#isolate id and sentence
	splitLine = line.split(" ")
	id = splitLine[0]
	sentenceTokens = splitLine[1:]

	#TODO clean special tokens
	
	#write to new file
	utteranceF = open(sys.argv[2] + id + ".gold", "wb")
	utteranceF.write(id + " " + " ".join(sentenceTokens))
	utteranceF.close()




