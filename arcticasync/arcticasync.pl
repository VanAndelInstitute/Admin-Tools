#!/usr/bin/perl

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  do a parallel sync the artica cryoem data from the instrument storage to the permanant storage
#  this assumes we have both mounted. we also change ownership to the core
#
##############################################################


use Time::HiRes qw(gettimeofday);
use File::Basename;
use strict;

#SETTINGS
my $RSYNC = "/primary/vari/software/rsync/3.1.2/bin/rsync";
my $THREADS = 10;
my $TIME = int (gettimeofday * 1000);
my $WORKDIR = "/primary/vari/admin/tools/arcticasync/logs/$TIME";
system("mkdir $WORKDIR");
my $listFile = "$WORKDIR/$TIME";
my $listFileParts = $TIME . "PART";
my $SRC = "/remote/arctica/";
my $DEST = "/primary/instruments/cryoem/arctica";
#################


#make sure this is not already running, die if we are.
my $numprocs = `pgrep arcticasync.pl | wc -l`;
chomp $numprocs;
system "echo already running > $WORKDIR/failed.log" if $numprocs != 1;
die "already running\n" if $numprocs != 1;


#make sure src and dest exist and are mounted
die unless length(`ls $SRC`) > 5;
die unless -e $SRC;
die unless -e $DEST;
die unless -e $WORKDIR;
chdir $WORKDIR;

#generate the exclude list
for my $e (glob("$SRC*"))
{
	my $ebase = basename($e);
	system("echo \"$ebase/\" >> $WORKDIR/excluded.list.txt") if ( ((-M $e) > 7) && -d $e ); 
}


#get the list of files to transfer
runcmd("$RSYNC --dry-run --safe-links -avxl --exclude-from \'$WORKDIR/excluded.list.txt\' $SRC $DEST | grep -v \"/\$\" | sort --random-sort  > $listFile");

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
		
		runcmd("$RSYNC -avxl --chown=cryoem:cryoem_users --files-from $WORKDIR/$p $SRC $DEST &> $WORKDIR/$p\.log") if -e "$WORKDIR/$p";
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

sub runcmd{
        my $cmd=shift @_;
        my $caller=(caller(1))[3];
        print STDERR "$caller\t$cmd\n";
        system($cmd);
}

