#!/usr/bin/env perl
use warnings;
use strict;

# takes given transcript in format:
#    TEXT ([utteranceID])
# converts to:
#    [utteranceID] TEXT

# ARGV[0] transcript to be formatted

#open file
my $transcript_file = $ARGV[0];

open(TRANSCRIPT, $transcript_file) or die "Can't open file.  Are you sure you have the correct path for $transcript_file?";

while (my $utterance = <TRANSCRIPT>) {
    $utterance =~ /(.+) \(([0-9A-z]+)\)/g;
    my $sentence = $1;
    my $utteranceID = $2;
    print("$utteranceID $sentence\n");
}

close TRANSCRIPT;