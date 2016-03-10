#!/usr/bin/env perl

#assumes pre-existing split of train and test wave files so just makes lists for each

$test_list = $ARGV[0];      #list of all files in training
$train_list = $ARGV[1];     #list of all files in testing

#write
open FL, $test_list;
open TESTLIST, ">$test_list";
#open TRAINLIST, ">$train_list";
while ($l = <FL>)
{
	chomp($l);
	print TESTLIST "$l\n";
}

open FL, $train_list;
open TRAINLIST, ">$train_list";
while ($l = <FL>)
{
	chomp($l);
	print TRAINLIST "$l\n";
}