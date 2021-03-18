#!/usr/bin/perl
use Time::HiRes qw(gettimeofday);
use strict;

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
# do a parallel sync the titan k3 cryoem data from the instrument storage to the permanant storage
#  this assumes we have both mounted. we also change ownership to the core
#
##############################################################



#SETTINGS
my $RSYNC = "/varidata/research/software/rsync/3.1.2/bin/rsync";
my $THREADS = 10;
my $TIME = int (gettimeofday * 1000);
my $WORKDIR = "/varidata/research/admin/tools/k3titansync/logs/$TIME";
system("mkdir $WORKDIR");
my $listFile = "$WORKDIR/$TIME";
my $listFileParts = $TIME . "PART";
my $SRC = "/remote/k3titan/Dosefractions/";
my $DEST = "/varidata/research/instruments/cryoem/titan/DoseFractions";
#################


#make sure this is not already running, die if we are. NOTE: pgrep truncates finding of the process name!
my $numprocs = `pgrep k3titansync.pl | wc -l`;
chomp $numprocs;
system "echo already running > $WORKDIR/failed.log" if $numprocs != 1;
die "already running\n" if $numprocs != 1;


#make sure src and dest exist and are mounted
die "src dir seems to be empty " . length(`ls $SRC`) unless length(`ls $SRC`) > 3;
die unless -e $SRC;
die unless -e $DEST;
die unless -e $WORKDIR;
chdir $WORKDIR;


#get the list of files to transfer
runcmd("$RSYNC --dry-run --safe-links -avxl $SRC $DEST | grep -v \"/\$\" | sort --random-sort  > $listFile");

#split the list into parts
my $lineCount = `wc -l < $listFile`;
system("echo nothing new to transfer > $WORKDIR/failed.log") if $lineCount <= 4;
die if $lineCount <= 4;
my $partSize = int ($lineCount / $THREADS ) + 1;
runcmd("split -l $partSize $listFile $listFileParts");

#for each part, start an rsync process in a new thread
my @parts = glob("$listFileParts*");

for my $p (@parts)
{
	my $pid = fork;
	if (not $pid) 
	{
		#transfer the files
		runcmd("$RSYNC -avxl --chown=cryoem:cryoem_users --files-from $WORKDIR/$p $SRC $DEST &> $WORKDIR/$p\.log");
		#then exit the child thread
		exit;
	}
}

#parent thread wait for all child threads
wait() for @parts;

#fix ownership
#runcmd("cd $DEST");
#my $chmodCmd = "chown -R cryoem:cryoem_users $DEST"; 
#runcmd($chmodCmd);

#delete files older than 4 hours

runcmd("find /remote/k3titan/Dosefractions -iname \"*.tif\" -mmin +1440 -type f -exec rm  {} \\;");

#cleanup
sub runcmd{
        my $cmd=shift @_;
        my $caller=(caller(1))[3];
        print STDERR "$caller\t$cmd\n";
        system($cmd);
}

