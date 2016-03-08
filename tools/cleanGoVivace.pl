#!/usr/bin/env perl
use warnings;
use strict;

# ARGV[0] = transcript to be cleaned

#open file

my $transcript_file = $ARGV[0];

open TRANSCRIPT, $transcript_file or die "Can't open file. Are you sure you have the correct path?";

while (my $line = <TRANSCRIPT>) {
    chomp my $line;
    my $lowerCase =~ s/([A-Z])/lc($1)/g;
    print $lowerCase;
}