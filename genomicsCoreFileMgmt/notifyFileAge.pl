#!/usr/bin/perl
use Net::SMTP;

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  notify genomics staff is trash is full
#
##############################################################

@dirs = ( "/secondary/projects/genomicscore/Core_Research_RawData");
$maxAge = 180;

for my $d (@dirs)
{
	next unless -e $d;
	my $outfull = `find $d -mtime +$maxAge`;
    email("sequencing-notifications\@vai.org","$d report on files older than $maxAge days",$outfull) if length($outfull) > 5;
}


sub email
{
	my $toLine = shift @_;
	my $from = "run.watch\@vai.org";
	my $subject = shift @_;
	my $message = shift @_;
	my $smtp = Net::SMTP->new('smtp.vai.org');
	my @to = split /,/, $toLine;
	$smtp->mail($from);
	if ($smtp->to(@to)) {
	     $smtp->data();
	     $smtp->datasend("To: $toLine\n");
	     $smtp->datasend("Subject: $subject\n");
	     $smtp->datasend("\n");
	     $smtp->datasend("$message\n");
	     $smtp->dataend();
	    } else {
	     print "Error: ", $smtp->message();
	    }
	    $smtp->quit;
}
