import sys

#calculates unique vocabulary size of a test set

#sys.argv[1] = transcripts file
#sys.argv[2] = list of files to analyze

#open files to test list
fTest = open(sys.argv[2], "rb")

#convert to list of files
testList = []

print("getting list of test files")
for line in fTest:
    testList.append(line)

fTest.close()

#open transcripts file
fTra = open(sys.argv[1], "rb")

#variable to house vocabulary
vocab = []

for line in fTra:
    lineSplit = line.rstrip().split(" ")
    id = lineSplit[0]
    words = lineSplit[1:]
    for w in words:
        print(w)
        if w.lower() not in vocab:
            vocab.append(w.lower())

fTra.close()

print(vocab)
print(len(vocab))
