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
@METRICS = ("ldavg-15");
@CUTOFFS = (0.05);
#@METRICS = ("LoadFive","LoadOne","LoadFifteen");
#@CUTOFFS = (0.5,0.5,0.5);
@QUEUES = ("longq","shortq","gpu");
$debugMSG = "";

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
		&printDebug("inspecting $jobName $userName $queueName $load $walltime\n"); 
		if($walltimeHour[1] >= 2 && 0.02 >= $load  &&  grep( /^$queueName$/, @QUEUES ))
		{ 
			&printDebug("testing idleness for $jobName $userName $queueName $load $walltime\n"); 
			my $returnValues = 0;
			$returnValues += checkMetric($nodeName,$METRICS[$_],$CUTOFFS[$_]) for (0..$#METRICS);
			unless ($returnValues)
			{
				my $msg = "Dear $userName,\n\n";
				$msg .= "This is an automated  email notifying you that your HPC3 Job #$jobName on $nodeName ";
				$msg .= "was idle for over 2 hours. As of 5/24/19, ";
				$msg .= "jobs that are idle for more than 2 hours will be stopped to ensure HPC resources are used effeciently.\n";
				$msg .= "An idle job is a job that has been allocated CPU cores and is running on a compute node, ";
				$msg .= "yet is not performing any computation.\n\n";
				$msg .= "For questions or concerns, please contact hpc3\@vai.org\n\n";
                $msg .= "https://vanandelinstitute.sharepoint.com/sites/SC/SitePages/HPC3-High-Performance-Cluster-and-Cloud-Computing.aspx\n\n";
				#email("$userName\@vai.org","HPC3 automatic idle job alert for job #$jobName ",$msg); 
				email("$userName\@vai.org","HPC auto idle job stopped #$jobName: $userName ",$msg); 
				killJob($jobName,"$userName running pbs job# $jobName on $nodeName will be killed"); 
                $msg .= `ssh $nodeName sar -q`;
                $msg .= $debugMSG;
				email("6926e14e.vai.org\@amer.teams.ms","HPC3 IDLE KILL job #$jobName: $userName\@vai.org ",$msg); 
			}
		}
	}
}


#check bright for the supplied metric. RETURN 0 if all values where below cutuff. RETURN 1 if we have a value that was above the idle cutoff
sub checkMetric
{
	my $node = shift @_;
	my $metricName = shift @_;
	my $cutoff = shift @_;
	my $cmd = "ssh $node sar -q | grep -v blocked | tail -n 14 | head -n 13 ";
	&printDebug("\t$cmd\n");
	my @metricListRaw = `$cmd`;
	
	if ($#metricListRaw < 12)
	{
		&printDebug("\t\tNot enough datapoints for qc metric: $metricName has $#metricListRaw values\n");
		return 1;
	}

	for (@metricListRaw)
	{
		my @line = split(/\s\s+/);
		chomp @line;
		my $metric = $line[5];
        if ($metric !~ /\d+\.\d+/)
        {
            &printDebug("\t\t datapoint was not a number: $metricName has $#metricListRaw values\n");
            return 1;
        }
		
		&printDebug("\t\t$node\.$metricName testing if $metric > $cutoff\t[". join(" ", @line) . "]\n");
		&printDebug("\t\t\tNODE IS NOT IDLE ($metric > $cutoff)\n") if $metric > $cutoff;
		return 1 if $metric > $cutoff;
	}
	return 0;
}

sub killJob
{
	my $jobID = shift @_;
	system("logger PBS_KILL_IDLE " . join(" ",@_) );
	&printDebug("KILLING JOB DUE TO VIOLATION\n");
	&printDebug("qdel $jobID\n");
	system("qdel $jobID");

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

sub printDebug 
{
  my $msg = join(" ",@_);  
  print STDERR $msg if $DEBUG;
  $debugMSG .= $msg;
}
