#!/usr/bin/perl

my @df = `df -h |grep sd`;
chomp @df;

for (@df)
{
	my @entry = split /\s+/;
	$entry[4] =~ /(\d+)/;
	my $usage = $1;
	system ("logger DANGER $entry[5] on head node at $usage percent full. OUT_OF_SPACE") if ($usage >= 98)
}
