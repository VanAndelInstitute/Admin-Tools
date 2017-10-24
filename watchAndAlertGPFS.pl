#!/usr/bin/perl
use Net::SMTP;

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  watch gpfs status and email when things change.
#
##############################################################


################################
#check for changes in mmgetstate vs the last time we ran this script, alert if changes.

$statusFile = "/root/mmgetstate.log.txt";
$statusFileTmp = "/root/mmgetstate.log.tmp.txt";
system("/usr/lpp/mmfs/bin/mmgetstate -a > $statusFile") unless -e $statusFile;
system("/usr/lpp/mmfs/bin/mmgetstate -a > $statusFileTmp");

#diff the old mmstate vs the one we did right now.
$diff = `diff -C 0 $statusFile $statusFileTmp`;
sendmail("mmgetstate status has changed since last check", $diff)  if length($diff) > 5;
system("mv $statusFileTmp $statusFile");

################################
### check fileset quota grace being full or in "expired" state
#ZR this is is a seperate script now

#my $homeCmd = "for i in `mmlsfileset  home | cut -f 1 -d ' ' | tail -n +3 | sort | xargs `; do echo \$i `mmlsquota -j \$i home --block-size auto  | tail -n 1 | sed 's/|.\\+//g' ` ; done ";
#my $scratchCmd = "for i in `mmlsfileset  scratch | cut -f 1 -d ' ' | tail -n +3 | sort | xargs `; do echo \$i `mmlsquota -j \$i scratch --block-size auto  | tail -n 1 | sed 's/|.\\+//g' ` ; done ";
#my $quota = `$homeCmd` . `$scratchCmd`;

#sendmail("Fileset quota looks to be full and grace expired", $quota)  if quota =~ /expired/i;


################################
##check for disks to be up and ready.

#get all gpfs volumes
my $volumesOut = `/usr/lpp/mmfs/bin/mmlsconfig  |grep dev\/`;
my @volumes = ($volumesOut =~ /dev\/(\w+)/g);

#then check each ones status
for my $vol (@volumes)
{
	my $lsdiskOut = `/usr/lpp/mmfs/bin/mmlsdisk $vol -e`;
	sendmail("GPFS mmlsdisk error on $vol",$lsdiskOut) unless $lsdiskOut =~ /All disks up and ready/;
}



################################

sub sendmail
{
	my $to = "hpcadmins\@vai.org";
	my $from = "gpfs1a\@vai.org";
	my $subject = $_[0];
	my $message = $_[1];
	my $smtp = Net::SMTP->new('smtp.vai.org');
	$smtp->mail($from);
	if ($smtp->to($to)) {
	     $smtp->data();
	     $smtp->datasend("To: $to\n");
	     $smtp->datasend("Subject: $subject\n");
	     $smtp->datasend("\n");
	     $smtp->datasend("$subject\n$message\n");
	     $smtp->dataend();
	    } else {
	     print "Error: ", $smtp->message();
	    }
	    $smtp->quit;
	system("logger "gpfs error: $subject");
}
