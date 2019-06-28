#!/usr/bin/perl
use Time::Local;
use Term::ANSIColor;
use Data::Dumper;
use Net::SMTP;

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  watch for users with low load average in PBS and email them a warning
#
##############################################################
my $DEBUG = 1 if $ARGV[0];
$DEPTH = "2h";
@METRICS = ("LoadFive","LoadOne","BytesRecv:eth0","BytesRecv:eth0","BytesRecv:ens1f1","BytesRecv:eth2");
@CUTOFFS = (0.5,0.5,20000,20000,20000,20000);
#@METRICS = ("LoadFive","LoadOne","LoadFifteen");
#@CUTOFFS = (0.5,0.5,0.5);
@QUEUES = ("longq","shortq","gpu");


$output = `/cm/shared/apps/torque/current/bin/pbsnodes`;
$zstatout = `/primary/vari/software/pbsPretty/zstat`;
foreach my $line (split '\n', $zstatout)
{
	chomp $line;
	$line =~ s/[\000-\037]\[(\d|;)+m//g;;
	$line =~ s/^\s+//;
	$line =~ s/\s+/|/g;
	my @z = split(/\|/, $line);
	$zstat{$z[0]} = [@z];
}

@nodes = split "\n\n", $output;

foreach  $n (@nodes)
{
	my @lines = split "\n", $n;
	$node = $lines[0];
	chomp $node;
	for $l (@lines)
	{
		if( $l =~ /\s*(\S*)\s+\=\s+(.+)$/)
		{
			$nodeprops{$node}{$1} = $2;
		}
	}
}

foreach $k (sort keys %nodeprops)
{
	my %nodejobs;
	my $cleanStatus = $nodeprops{$k}{status};
	$cleanStatus =~ s/\(.+\)//g;
	my %detailedProps = split /[,=]/, $cleanStatus;
	
	$color = $nodeprops{$k}{jobs} =~ /s+/ ? "red" : "green";
	$nodeprops{$k}{jobs} =~ s/\-\d+.master.cm.cluster//g;
	$nodeprops{$k}{jobs} =~ s/\[.+\]//g;
	$nodeprops{$k}{jobs} =~ s/.master.cm.cluster//g;
	$nodeprops{$k}{jobs} =~ s/ //g;
	for my $core ( split ",",$nodeprops{$k}{jobs})
	{
		my $jobNum = $core;
		$jobNum =~ s/[\d-]+\///g;
		my $coreNum = $core;
		$coreNum =~ s/\/.+//;
		$nodejobsCores{$jobNum} = $coreNum;
	}
	$nodeprops{$k}{jobs} =~ s/[\d-]+\///g;
	$nodejobs{$_} ++  for split ",",$nodeprops{$k}{jobs};
	if(scalar(keys %nodejobs)  == 1)
	{
		my $nodeName = $k;
		my $jobName = $nodeprops{$k}{jobs}; 
		my $userName = $zstat{$jobName}[2]; 
		my $queueName = $zstat{$jobName}[5]; 
		my $walltime = $zstat{$jobName}[4]; 
		my $load = $detailedProps{loadave}; 
		my @walltimeHour = split(":",$walltime);
		if($walltimeHour[1] >= 2 && $load < "0.02" &&  grep( /^$queueName$/, @QUEUES ))
		{ 
			print STDERR "testing idleness for $jobName $userName $queueName $load $walltime\n" if $DEBUG;
			my $returnValues = 0;
			$returnValues += checkMetric($nodeName,$METRICS[$_],$CUTOFFS[$_]) for (0..$#METRICS);
			unless ($returnValues)
			{
				killJob($jobName);
				my $msg = "Dear $userName,\n\n";
				$msg .= "This is an automated  email notifying you that your HPC3 Job #$jobName on $nodeName ";
				$msg .= "was idle for over 2 hours (system load=0.00) and has new been stopped and deleted\n";
				$msg .= "\n\n";
				$msg .= "An idle job is a job that has been allocated CPU cores and is running on a compute node, ";
				$msg .= "yet is not performing any computation. In response to community demand, HPC will now end ";
				$msg .= "these jobs to ensure that resources are used effeciently.\n\n";
				$msg .= "For questions or concerns, please contact hpc3\@vai.org\n";
				#email("$userName\@vai.org","HPC3 automatic idle job alert for job #$jobName ",$msg); 
				email("hpcadmins\@vai.org","HPC3 IDLE KILL job #$jobName: $userName\@vai.org ",$msg); 
				killJob($jobName,"$userName running pbs job# $jobName on $nodeName will be killed"); 
			}
		}
	}
}



sub checkMetric
{
	my $node = shift @_;
	my $metricName = shift @_;
	my $cutoff = shift @_;
	my $cmd = "cmsh --command \"device dumpmetricdata -$DEPTH now --raw  $metricName $node\"";
	print "\t$cmd\n" if $DEBUG;
	my @metricListRaw = `$cmd`;
	shift @metricListRaw;

	for (@metricListRaw)
	{
		my $line = $_;
		chomp $line;
		$line =~ /([0-9\.]+)\D*$/;
		my $metric = $1;
		
		print STDERR "\t$node\.$metricName testing if $metric > $cutoff\n" if $DEBUG;
		print STDERR "\tNODE IS NOT IDLE ($metric > $cutoff)" if $metric > $cutoff && $DEBUG;
		return 1 if $metric > $cutoff;
	}
	return 0;
}

sub killJob
{
	my $jobID = shift @_;
	system("logger PBS_KILL_IDLE " . join(" ",@_) );
	print STDERR "KILLING JOB DUE TO VIOLATION\n" if $DEBUG;
	print STDERR "qdel $jobID\n" if $DEBUG;
	#system("qdel $jobID");

}


sub email
{
	my $to = shift @_;
	my $from = "hpc3\@vai.org";
	my $subject = shift @_; 
	my $message = shift @_;
	my $smtp = Net::SMTP->new('smtp.vai.org');
	$smtp->mail($from);
	if ($smtp->to($to)) {
	     $smtp->data();
	     $smtp->datasend("To: $to\n");
	     $smtp->datasend("Subject: $subject\n");
	     $smtp->datasend("\n");
	     $smtp->datasend("$message\n");
	     $smtp->dataend();
	    } else {
	     print "Error: ", $smtp->message();
	    }
	    $smtp->quit;
}
