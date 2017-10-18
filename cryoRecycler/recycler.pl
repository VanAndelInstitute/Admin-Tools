#!/usr/bin/perl
use Time::HiRes qw(gettimeofday);
use strict;

#SETTINGS
my $RSYNC = "/primary/vari/software/rsync/3.1.2/bin/rsync";
my $THREADS = 10;
my $TIME = int (gettimeofday * 1000);
my $WORKDIR = "/primary/vari/admin/tools/cryoRecycler/logs/$TIME";
system("mkdir $WORKDIR");
my $listFile = "$WORKDIR/$TIME";
my $listFileParts = $TIME . "PART";
my $SRC = shift @ARGV || die;
my $DEST = shift @ARGV || die;;
my $AGE = 30;
#################


#make sure this is not already running, die if we are.
my $numprocs = `pgrep recycler.pl | wc -l`;
chomp $numprocs;
system "echo already running > $WORKDIR/failed.log" if $numprocs != 1;
die "already running\n" if $numprocs != 1;


#make sure src and dest exist and are mounted
die unless length(`ls $SRC`) > 5;
die unless -e $SRC;
die unless -e $DEST;
die unless -e $WORKDIR;


#get the list of files to transfer
chdir $SRC;
runcmd("find -type f -mtime +$AGE | sort --random-sort > $listFile");
#runcmd("$RSYNC --dry-run --safe-links -avvvxl $SRC $DEST | grep -v \"/\$\" | sort --random-sort  > $listFile");

chdir $WORKDIR;
#split the list into parts
my $lineCount = `wc -l < $listFile`;
system("echo nothing new to transfer > $WORKDIR/failed.log") if $lineCount <= 1;
die if $lineCount <= 1;
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
		runcmd("$RSYNC -avxl --exclude=160\\ apps\\ cd --chown=gongpu.zhao:cryoem_users --files-from $WORKDIR/$p $SRC $DEST &> $WORKDIR/$p\.log");

		#delete the old files
		open my $handle, "<$WORKDIR/$p";
		chomp(my @fileLines = <$handle>);
		close $handle;
		my $logMsg;
		$logMsg .= &delete_file($_) for @fileLines;
		
		#then exit the child thread
		open my $delFH, ">$WORKDIR/$p.del.log";
		print $delFH $logMsg; 
		close $delFH;
		exit;
	}
}

#parent thread wait for all child threads
wait() for @parts;

#delete a file
sub delete_file
{
	my $del = shift @_;
	my $delDEST = "$DEST/$del";
	my $delSRC = "$SRC/$del";
	if (-f $delSRC && -f $delDEST &&  -s $delSRC == -s $delDEST && $delSRC ne $delDEST && -M $delSRC > $AGE)
	{
		unlink $delSRC;
		return "deleting $delSRC since age " . (-M $delSRC) . ">$AGE. file mirrored to $delDEST size=" . (-s $delDEST) . "\n";
	}
	else
	{
		return "COULD NOT DELETE $delSRC since age " . (-M $delSRC) . ">$AGE. file mirrored to $delDEST size=" . (-s $delDEST) . "\n";
	}
}


sub runcmd{
        my $cmd=shift @_;
        my $caller=(caller(1))[3];
        print STDERR "$caller\t$cmd\n";
        system($cmd);
}

