#!/usr/bin/env perl
use warnings;
use strict;

# cleans transcripts before computing WER by
    # (1) removing punctuation and uppercase
    # (2) prepending the line with a line ID (required by ./compute-wer.cc)
# puts new file "-cleaned.txt" in same location as original

# ARGV[0] = transcript to be cleaned
# ARGV[1] = optional: utterance ID or ""    #if the utteranceID is part of the transcript already enter ""
# ARGV[2] = optional: full path location for cleaned file

#open file
my $transcript_file = $ARGV[0];

open(TRANSCRIPT, $transcript_file) or die "Can't open file. Are you sure you have the correct path?";

use File::Basename;

#get just filename (without extension)
my ($filename, $dirs, $suffix) = fileparse($transcript_file);
$filename =~ s/(.+)\..+/$1/;        #removes file extension

my $newFilePath;
#create new file
if (scalar @ARGV < 3) {            #if no second command line argument given
    $newFilePath = "$dirs$filename-cleaned.txt";
} else {
    $newFilePath = $ARGV[2];        #if path given as second command line argument
}

open(my $output, ">", $newFilePath);

#my $i = 0;

#clean
while (my $line = <TRANSCRIPT>) {
#    $i++;
    if ($ARGV[1] eq "") {           #if utterance ID already present
        my @splitLine = split(/ /, $line);       #convert to array
        my $utteranceID = $splitLine[0];
        my $sentenceLength = (scalar @splitLine) - 1;  #calculate length of sentence
        my @sentenceTokens = @splitLine[1..$sentenceLength];    #take tokens of sentence (dropping existing utteranceID)
        my $sentence = join(" ", @sentenceTokens);
        $sentence =~ s/([A-Z])/\L$1/g;      #convert all to lowercase
        $sentence =~ s/%[a-z]+//g;          #remove %HESITATION (used by Watson)
        $sentence =~ s/\p{Punct}//g;               #remove punctuation
        $sentence =~ s/ {2,}/ /g;              #remove extra spaces
        print($output "$utteranceID $sentence")
    } else {
        $line =~ s/([A-Z])/\L$1/g;      #convert all to lowercase
        $line =~ s/%[a-z]+//g;          #remove %HESITATION (used by Watson)
        $line =~ s/\p{Punct}//g;               #remove punctuation
        $line =~ s/ {2,}/ /g;              #remove extra spaces
        print($output "$ARGV[1] $line");
    }
}

close TRANSCRIPT;
close $output;