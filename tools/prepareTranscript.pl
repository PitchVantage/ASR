#!/usr/bin/env perl
use warnings;
use strict;

# cleans transcripts before computing WER by
    # (1) removing punctuation and uppercase
    # (2) prepending the line with a line ID (required by ./compute-wer.cc)
# puts new file "-cleaned.txt" in same location as original

# ARGV[0] = transcript to be cleaned
# ARGV[1] = optional: full path location for cleaned file

#open file
my $transcript_file = $ARGV[0];

open(TRANSCRIPT, $transcript_file) or die "Can't open file. Are you sure you have the correct path?";

use File::Basename;

#get just filename (without extension)
my ($filename, $dirs, $suffix) = fileparse($transcript_file);
$filename =~ s/(.+)\..+/$1/;        #removes file extension

my $newFilePath;
#create new file
if (scalar @ARGV == 1) {            #if no second command line argument given
    $newFilePath = "$dirs$filename-cleaned.txt";
} else {
    $newFilePath = $ARGV[1];        #if path given as second command line argument
}

open(my $output, ">", $newFilePath);

my $i = 0;

#clean
while (my $line = <TRANSCRIPT>) {
    $i++;
    $line =~ s/([A-Z])/\L$1/g;      #convert all to lowercase
    $line =~ s/[\.\,\?\-]//g;               #remove punctuation
    $line =~ s/ {2,}/ /g;              #remove extra spaces
    print($output "$i $line");
}

close TRANSCRIPT;
close $output;