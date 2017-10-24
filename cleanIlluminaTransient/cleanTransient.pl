#!/usr/bin/perl
#
#

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  
#
##############################################################



$base = "/primary/instruments/sequencing/illumina/incoming";


@files = glob("$base/*/Data/Intensities/BaseCalls/*_L00[1234]_??_???.fastq.gz");



for my $f (@files)
{
	die if $f =~ /L000/;
	my $merged = $f;
	$merged =~ s/_S\d_/_/;
	$merged =~ s/L00\d/L000/;

	runcmd("rm $f") if -s $merged > -s $f && -e $merged && -e $f;
	print "\t(data is already in merged file $merged\n\n" if -s $merged > -s $f && -e $merged && -e $f;


}

sub runcmd{
	my $cmd=shift @_;
	my $caller=(caller(1))[3];
	print  "$caller\t$cmd\n";
	system($cmd) if $ARGV[0] eq "y";
}
