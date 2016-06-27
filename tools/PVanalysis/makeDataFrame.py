import re
import pandas as pd


#makes a data frame out of .results file

# (1) run .parseResults(.results)
# (2) run .makeDataFrame(output of 1)
# (3) run .calculateTotal(output of 2, "WER")

#parse .results file into dictionary (that can be converted to data frame
    #key is field
    #value is list of values for fields (each item in list is a row in dataframe)
def parseResults(f):
    data = open(f, "rb")

    #initialize dict
    dict = {}
    #initialize value lists
    dict["title"] = []
    dict["WER"] = []
    dict["inc_words"] = []
    dict["total_words"] = []
    dict["insertions"] = []
    dict["deletions"] = []
    dict["substitutions"] = []
    dict["SER"] = []
    dict["inc_utterances"] = []
    dict["total_utterances"] = []

    #regexes
    #nan
    nanRegex = r'.*nan.*'
    #SER
        #group 1 = SER
        #group 2 = incorrect utterances
        #group 3 = total utterances
    serRegex = r'\%SER ([0-9]+\.[0-9]{2}) \[ ([0-9]+) \/ ([0-9]+) \]'
    #WER
        #group 1 = WER
        #group 2 = incorrect words
        #group 3 = total words
        #group 4 = insertions
        #group 5 = deletions
        #group 6 = insertions
        #group 7 = deletions
        #group 8 = substitutions
    werRegex = r'\%WER ([0-9]+\.[0-9]{2}) \[ ([0-9]+) \/ ([0-9]+), ([0-9]+) ins, ([0-9]+) del, ([0-9]+) sub \]'

    #iterate through lines
    for line in data:
        if line.startswith("%SER"):
            #is SER
            matched = re.match(serRegex, line.rstrip())
            if re.match(nanRegex, line):
                dict["SER"].append("NaN")
                dict["inc_utterances"].append(0.0)
                dict["total_utterances"].append(0.0)
            else:
                dict["SER"].append(float(matched.group(1)))
                dict["inc_utterances"].append(float(matched.group(2)))
                dict["total_utterances"].append(float(matched.group(3)))
        elif line.startswith("%WER"):
            #is WER
            matched = re.match(werRegex, line.rstrip())
            if re.match(nanRegex, line):
                dict["WER"].append("NaN")
                dict["inc_words"].append(0.0)
                dict["total_words"].append(0.0)
                dict["insertions"].append(0.0)
                dict["deletions"].append(0.0)
                dict["substitutions"].append(0.0)
            else:
                dict["WER"].append(float(matched.group(1)))
                dict["inc_words"].append(float(matched.group(2)))
                dict["total_words"].append(float(matched.group(3)))
                dict["insertions"].append(float(matched.group(4)))
                dict["deletions"].append(float(matched.group(5)))
                dict["substitutions"].append(float(matched.group(6)))
        elif not line.startswith("=") and not line.startswith("Scored"):
            #is title
            dict["title"].append(line.rstrip())

    data.close()
    return dict

#make dataframe
def makeDataFrame(dict):
    df = pd.DataFrame(dict)

    return df

#df.describe()

#calculate total WER
    #df = DataFrame
    #errorType = "WER" or "SER"
def calculateTotal(df, errorType):
    if errorType == "WER":
        all = df["total_words"].sum()
        all_inc = df["inc_words"].sum()
    elif errorType == "SER":
        all = df["total_utterances"].sum()
        all_inc = df["inc_utterances"].sum()
    else:
        all = df["total_words"].sum()
        all_inc = df["inc_words"].sum()

    return (all_inc / all) * 100



