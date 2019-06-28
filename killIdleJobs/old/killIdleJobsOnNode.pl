#!/usr/bin/perl

$DEPTH = "2h";
#@METRICS = ("LoadFive","LoadOne","BytesRecv:eth0","BytesRecv:eth0","BytesRecv:ens1f1","BytesRecv:eth2");
#@CUTOFFS = (0.5,0.5,20,20,20,20);
@METRICS = ("LoadFive","LoadOne","LoadFifteen");
@CUTOFFS = (0.5,0.5,0.5);

my $node = $ARGV[0] || die "node name needed";
$node =~ /node\d+/ || die "invalid node name";
chomp $node;


#check if job walltime is over 2 hours

#check if node is idle during that timeframe
checkMetric($node,$METRICS[$_],$CUTOFFS[$_]) for (0..$#METRICS);

#if we havent exited by now, then kill job
killJob();

sub checkMetric
{
	my $node = shift @_;
	my $metricName = shift @_;
	my $cutoff = shift @_;
	my @metricListRaw = `cmsh --command \"device dumpmetricdata -$DEPTH now  $metricName $node\"`;
	shift @metricListRaw;

	for (@metricListRaw)
	{
		my $line = $_;
		chomp $line;
		$line =~ /([0-9\.]+)\D*$/;
		my $metric = $1;
		print STDERR "$node\.$metricName testing if $metric > $cutoff\n";
		exitNoKill("$node\.$metricName: $line") if $metric > $cutoff;
	}
}

sub exitNoKill
{
	#exit because we found load
	print STDERR "Node has load, WILL NOT KILL JOB\n\t" .  $_[0] . "\n";	
	exit;
}

sub killJob
{
	system("logger PBS_KILL_IDLE $node " . join(" ",@_) );
	print STDERR "KILLING JOB DUE TO VIOLATION\n";
}
