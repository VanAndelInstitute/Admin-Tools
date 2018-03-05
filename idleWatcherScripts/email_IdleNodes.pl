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
		my $load = $detailedProps{loadave}; 
		my $msg = "Dear $userName,\n\n";
		$msg .= "This is an automated courtesy email notifying you that your HPC3 Job #$jobName on $nodeName appears to be idle (system load=0.00)\n";
		$msg .= "An idle job is a job that has been allocated CPU cores and is running on a compute node, yet does not appear to be doing anything. ";
		$msg .= "This may be due to a forgotten interactive job, a broken job script or a job that has hung. \n";
		$msg .= "It's also possible that you just submitted your job and we've accidently detected it as being idle before it has started processing, or that the idleness is an expected computational phase of your processing, in which case you can ignore this message \n";
		$msg .= "To ensure that this shared resource is effeciently utilized, we ask that you inspect Job $jobName and verify that it is running correctly.\n";
		$msg .= "For questions or concerns, please contact hpc3\@vai.org\n";
		$msg .= "Thanks, \n";
		$msg .= "-The HPC3 Admins \n";
		email("$userName\@vai.org","HPC3 automatic idle job alert for job #$jobName ",$msg) if $load eq "0.00" ;
		#email("zack.ramjan\@vai.org","HPC3 automatic idle job alert for job #$jobName: $userName\@vai.org ",$msg) if $load eq "0.00" ;
		system("logger -t PBS_IDLE $userName running pbs job# $jobName on $nodeName is running an idle job with load 0.00 , user has been emailed") if $load eq "0.00";
	}
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
