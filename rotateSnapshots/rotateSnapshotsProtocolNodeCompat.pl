#!/usr/bin/perl
use POSIX qw(strftime);
use strict;

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  Perform the regular snapshots and get rid of old ones. we keep a number of
# trailing weeks and days and then trash the ones beyond that.
# this is run from cron
#
##############################################################



my $date = `date -u +\@GMT-\%Y.\%m.\%d-\%H.\%M.\%S`;
chomp $date;
my $today =  strftime "%a", localtime;
my $gpfsBin = "/usr/lpp/mmfs/bin";
my $maxDaily = 6;


#make sure this is not already running, die if we are.
my @numprocs = `pgrep -f rotateSnapshotsProtocolNodeCompat.pl`;
print STDERR scalar(@numprocs);
die "already running\n" if scalar(@numprocs) != 1;
my $fs = $ARGV[0];
die  "specify GPFS device" unless $fs eq "scratch" || $fs eq "home";

takeSnapShot($fs,"$date");
my @snapShots = getSnapShots($fs, "GMT");
removeSnapShot($fs,$snapShots[0]) if scalar(@snapShots) > $maxDaily;

##################SUBS##################

sub takeSnapShot
{
	my $volume = shift@_;
	my $label = shift @_;
	runcmd("$gpfsBin/mmcrsnapshot $volume $label -j root");	
}

sub getSnapShots
{
	my $volume = shift @_;
	my $filter = shift @_;
	my @output = split /\n/, `$gpfsBin/mmlssnapshot $volume`;
	shift @output;
	shift @output;
	s/(\S+).+/$1/ for @output;
	@output = grep /$filter/, @output;	
    print "$_\n" for @output;
	return sort @output;
}

sub removeSnapShot
{
	my $volume = shift @_;
	my $label = shift @_;
    runcmd("$gpfsBin/mmdelsnapshot $volume $label -j root");
}

sub runcmd{
	my $cmd=shift @_;
	my $caller=(caller(1))[3];
	print STDERR "$caller\t$cmd\n";
	system($cmd);
}
