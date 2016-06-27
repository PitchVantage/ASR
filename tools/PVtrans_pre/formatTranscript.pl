#!/usr/bin/env perl
use warnings;
use strict;

# takes given transcript in format:
#    TEXT ([utteranceID])
# converts to:
#    [utteranceID] TEXT

# ARGV[0] transcript to be formatted

#perl formatTranscript.pl path/to/transcript/to/be/formatted.txt

#open file
my $transcript_file = $ARGV[0];

open(TRANSCRIPT, $transcript_file) or die "Can't open file.  Are you sure you have the correct path for $transcript_file?";

while (my $utterance = <TRANSCRIPT>) {
    #matches two groups
        #$1 is the utterance ID
        #$2 is the sentence
    $utterance =~ /(.+) \(([0-9A-z]+)\)/g;
    my $sentence = $1;
    my $utteranceID = $2;
    print("$utteranceID $sentence\n");  #prints to STDOUT
}

close TRANSCRIPT;