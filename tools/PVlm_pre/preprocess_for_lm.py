from nltk.tokenize import sent_tokenize, word_tokenize
import sys
import re
import ast

# This script takes a plain `.txt` file and preprocesses it for use in a language model

# Puts one sentence per line (using `nltk` `sent_tokenizer`)
# splits hyphenated words
# Removes all punctuation
# Uppercases everything
# Removes all sentences with a cardinal number (in number format)
# rejoin contractions [parameterized]

# sys.argv[1] = full path to text file
# sys.argv[2] = full path to clean output file
# sys.argv[3] = boolean: rejoin contractions
# sys.argv[4] = boolean: line separated (each line considered a document)

############

# detect hyphenated words
is_hyphenated = lambda x: "-" in x


# returns hyphenated word split into two
def det_is_hyphenated(token):
    if is_hyphenated(token):
        split_string = token.partition("-")
        return split_string[0] + " " + split_string[2]
    else:
        return token

# detect punctuation
is_punctuation = lambda x: not x.isalnum()
punct_to_keep_regex = r'\'?\w+[\.\']?\w*'

is_punct_to_keep = lambda x: not not re.match(punct_to_keep_regex, x)

# strips . used in abbreviation that was originally kept
def strip_kept_punct(word):
    regex = r'\.'
    return re.sub(regex, "", word)

# returns word if not punctuation
def det_is_punctuation(token):
    if not is_punctuation(token) or is_punct_to_keep(token):
        return token


# detect numbers
num_regex = r'[0-9]'
is_num = lambda x: not not re.match(num_regex, x)


# make uppercase
def make_sent_upper(sentence):
    return [token.upper() for token in sentence]


# returns sentence if doesn't contain numbers
def det_contains_num(sentence):
    booleans = [is_num(token) for token in sentence]
    if True not in booleans:
        return sentence


# rejoin contractions
is_contraction = lambda x: "'" in x and (x.startswith("'") or x.startswith("N"))


# merges contractions in tokenized sentence
def merge_contractions(sentence):
    output_tokens = []
    for i in range(len(sentence)):
        current_token = sentence[i]
        if i != len(sentence) - 1 and not is_contraction(current_token):
            next_token = sentence[i+1]
            if is_contraction(next_token):
                output_tokens.append(current_token + next_token)
            else:
                output_tokens.append(current_token)
        elif i == len(sentence) - 1 and not is_contraction(current_token):
            output_tokens.append(current_token)
    return output_tokens


# filters nones
def filter_none(sentence):
    return list(filter(lambda x: x, sentence))

############

f_in = open(sys.argv[1], 'r')
f_out = open(sys.argv[2], 'w')
rejoin = ast.literal_eval(sys.argv[3])
line_separated = ast.literal_eval(sys.argv[4])


def clean_all(text, f_out):
    sentences = sent_tokenize(text)
    # iterate through sentences
    for sent in sentences:
        # tokenize
        sent_tokenized = word_tokenize(sent)
        # split hyphenated
        sent_tokenized = [det_is_hyphenated(token) for token in sent_tokenized]
        # remove sentence if contains numbers
        sent_tokenized = det_contains_num(sent_tokenized)
        if sent_tokenized:
            # remove punctuation
            sent_tokenized = filter_none([det_is_punctuation(token) for token in sent_tokenized])
            # make uppercase
            sent_tokenized = make_sent_upper(sent_tokenized)
            if rejoin:
                sent_tokenized = merge_contractions(sent_tokenized)
            # strip originally kept punctuation
            sent_tokenized = [strip_kept_punct(token) for token in sent_tokenized]
            # make into string
            sent_string = " ".join(sent_tokenized)
            f_out.write(sent_string + "\n")

if line_separated:
    c = 0
    for line in f_in:
        c += 1
        if c % 10 == 0:
            print("processing line " + str(c))
        clean_all(line, f_out)
else:
    all_text = f_in.read()
    clean_all(all_text, f_out)

f_in.close()
f_out.close()

