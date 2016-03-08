#!/usr/bin/env perl
use warnings;
use strict;

# cleans transcripts before computing WER by
# removing periods and uppercase
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

#clean
while (my $line = <TRANSCRIPT>) {
    $line =~ s/([A-Z])/\L$1/g;      #convert all to lowercase
    $line =~ s/\.//g;               #remove periods
    $line =~ s/  / /g;              #remove extra spaces
    print($output $line);
}

close TRANSCRIPT;
close $output;