#!/usr/bin/env perl

#generates train/test split from a list of wave files

$full_list = $ARGV[0];              #list of all wave files
$test_list = $ARGV[1];              #new file name for test waves
$train_list = $ARGV[2];             #new file name for train waves
my $trainPercentage;
#if command line argument is given, use that split
if (scalar @ARGV == 4) {
    $trainPercentage = $ARGV[3];        #percentage (in decimal) to be used in training
                                        #NOTE: rounds down
} else {
#else default to 80/20
    $trainPercentage = .8;
}


#open full_list file
open FL, $full_list;
$nol = 0;

#count length of lines?
while ($l = <FL>)
{
	$nol++;
}
close FL;


$i = 0;
open FL, $full_list;
open TESTLIST, ">$test_list";
open TRAINLIST, ">$train_list";

#for each line, split between test and train
while ($l = <FL>)
{
	chomp($l);
	$i++;
#	if ($i <= $nol/2 )                      #put first half in train
	if ($i <= $nol * $trainPercentage )     #put first X percent in train
	{
		print TRAINLIST "$l\n";
	}
	else                                    #put rest in test
	{
		print TESTLIST "$l\n";
	}
}
