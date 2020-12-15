#!/usr/bin/perl
use Net::SMTP;
use POSIX qw(strftime);

##############################################################
#  
#  Author     :  Zack Ramjan
#  Company    : Van Andel Institute
#  Description: 
#  Find files and move them to staging area for archival
#
##############################################################

@dirs = ( "/secondary/projects/genomicscore/.archive");
$maxAge = 180;
my $ydm = strftime "%Y%m%d", localtime;
my $archiveDir = ".uploadToAWS_$ydm";
print $date;

for my $d (@dirs)
{
	next unless -e $d;
    chdir $d;
	my @moveDirList = `find . -maxdepth 1 -type d -ctime +$maxAge`;
    chomp @moveDirList;
    next unless @moveDirList;
    system("mkdir ../$archiveDir") unless -d "../$archiveDir";
    system("chown \"marie.adams:sequencing technology\" ../$archiveDir") unless -d "../$archiveDir";
    email("sequencing-notifications\@vai.org","$d files moved to $archiveDir, older than $maxAge days",join("\n",@moveDirList)); 

    for $movedDir (@moveDirList)
    {
        next unless -e $movedDir && -d $movedDir;
        system "mv \"$movedDir\" \"../$archiveDir\""
    }
    system("chown -R \"marie.adams:sequencing technology\" ../$archiveDir") if -d "../$archiveDir";
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
