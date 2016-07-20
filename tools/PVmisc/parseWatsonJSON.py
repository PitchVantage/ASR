import json
import sys

# sys.argv[1] = json file path
# sys.argv[2] = clean txt file location

# python parseWatsonJSON.py /path/to/original.json /path/to/cleaned_output.txt

data = json.load(open(sys.argv[1]))
write = open(sys.argv[2], "wb")

results = data["results"]

for i in range(len(results)):
	write.write(results[i]["alternatives"][0]["transcript"])

write.close()