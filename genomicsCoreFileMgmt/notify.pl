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

@dirs = ( "/primary/instruments/sequencing/illumina/incoming/.trash", "/primary/instruments/iscan/.trash", "/primary/projects/genomicscore/.trash","/primary/instruments/sequencing/novaseq/.trash", "/primary/instruments/sequencing/iSeq/.trash");


for my $d (@dirs)
{
	next unless -e $d;
	my $out = `ls $d`;
	my $outfull = "$d:\n" . `ls -l $d`;
    #email("marie.adams\@vai.org,ben.johnson\@vai.org,zack.ramjan\@vai.org","$d needs to be cleaned",$outfull) if length($out) > 5;
    email("sequencing-notifications\@vai.org","$d needs to be cleaned",$outfull) if length($out) > 5;
    #email("zack.ramjan\@vai.org","$d needs to be cleaned", $outfull) if length($out) > 5;
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
