import sys
import ast

# This script will take in a LIUM `.seg` file 
# and output it in the form needed by `kaldi` for `segments` file

# sys.argv[1] = <str>, full path to `.seg` file
# sys.argv[2] = <str>, full path to output (`kaldi`) `segments` file
# sys.argv[3] = <bool>, whether to interleave speaker segments chronologically
"""
original LIUM `.seg` file:
    ;; cluster S0 [ score:FS = -33.21533931236815 ] [ score:FT = -33.21200366337356 ] [ score:MS = -33.10055266054032 ] [ score:MT = -33.13208342603428 ]
    phone_convo.wav 1 0 1781 M S U S0
    phone_convo.wav 1 3087 997 M S U S0
    phone_convo.wav 1 4084 874 M S U S0
    phone_convo.wav 1 4958 1708 M S U S0
    phone_convo.wav 1 6666 222 M S U S0
    phone_convo.wav 1 6888 418 M S U S0
    phone_convo.wav 1 7306 1347 M S U S0
    phone_convo.wav 1 8653 1176 M S U S0
    phone_convo.wav 1 11295 275 M S U S0
    phone_convo.wav 1 11570 1786 M S U S0
    ;; cluster S14 [ score:FS = -33.603977588747966 ] [ score:FT = -33.65048466871852 ] [ score:MS = -33.13851206174335 ] [ score:MT = -33.411694176534134 ]
    phone_convo.wav 1 1781 1306 M S U S14
    phone_convo.wav 1 9829 1466 M S U S14
    phone_convo.wav 1 13356 573 M S U S14

necessary output for `kaldi`:
    S0 phone_convo-00-1781 0.0 17.81
    S14 phone_convo-1781-3087 17.81 30.87
    S0 phone_convo-3087-4084 30.87 40.84
    S0 phone_convo-4084-4958 40.84 49.58
    S0 phone_convo-4958-6666 49.58 66.66
    S0 phone_convo-6666-6888 66.66 68.88
    S0 phone_convo-6888-7306 68.88 73.06
    S0 phone_convo-7306-8653 73.06 86.53
    S0 phone_convo-8653-9829 86.53 98.29
    S14 phone_convo-9829-11295 98.29 112.95
    S0 phone_convo-11295-1157 112.95 115.7
    S0 phone_convo-1157-13356 115.7 133.56
    S14 phone_convo-13356-13929 133.56 139.29
"""

seg_in = sys.argv[1]
seg_out = sys.argv[2]
interleave = ast.literal_eval(sys.argv[3])


def to_string(tup):
    return " ".join([tup[0], tup[1], str(tup[2]), str(tup[3])])

f_in = open(seg_in, "r")

# dictionary to hold speaker ID, gender, and segments
speakers = {}

# iterate through each line of original file
for line in f_in:
    # skip lines with cluster (speaker) information
    if not line.startswith(";;"):
        audio_file, _, start, length, gender, _, _, speaker_id = line.rstrip().split(" ")
        start = int(start)
        stop = start + int(length)
        # convert start time to seconds
        start *= .01
        # convert stop time to seconds
        stop *= .01
        # get  audio ID (without .wav)
        audio_id = audio_file[:-4]
        # create segment ID
        start_id = str(start).replace(".", "")
        stop_id = str(stop).replace(".", "")
        segment_id = "-".join((audio_id, start_id, stop_id))
        # build relevant line for `kaldi` segments file
        kaldi_segment_line = (speaker_id, segment_id, start, stop)
        if speaker_id not in speakers:
            # begin dictionary
            speakers[speaker_id] = {}
            speakers[speaker_id]["gender"] = gender
            speakers[speaker_id]["segments"] = []
        # add segment to dictionary
        speakers[speaker_id]["segments"].append(kaldi_segment_line)
f_in.close()

f_out = open(seg_out, "w")

first = ""
# determine which speaker began the audio file
for speaker in speakers:
    if speakers[speaker]["segments"][0][2] == 0.0:
        first = speaker
if interleave:
    # unsorted_list.sort(key=lambda x: int(x[3]))
    # make one list of lists of all speakers' segments
    all_segments = []
    for speaker in speakers:
        for seg in speakers[speaker]["segments"]:
            all_segments.append(seg)
    for i in all_segments:
        print(i)
    # sort all_segments
    # all_segments_sorted = all_segments.sort(key=lambda x: x[2])
    all_segments_sorted = sorted(all_segments, key=lambda x: x[2])
    for seg in all_segments_sorted:
        # convert floats to string and rebuild segment line
        seg_out = to_string(seg)
        f_out.write(seg_out + "\n")
else:
    for seg in speakers[first]["segments"]:
        # convert floats to string and rebuild segment line
        seg_out = to_string(seg)
        f_out.write(seg_out + "\n")
        for speaker in speakers:
            if speaker != first:
                for seg in speakers[speaker]["segments"]:
                    # convert floats to string and rebuild segment line
                    seg_out = to_string(seg)
                    f_out.write(seg_out + "\n")

f_out.close()



