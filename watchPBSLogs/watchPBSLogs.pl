#!/usr/bin/perl
use IO::Handle;

my $throttle = 0;
my $newestLog = "empty";;

for (;;) 
{
	if($newestLog ne getLatestLog())
	{
		$newestLog = getLatestLog();
		open (LOGFILE, $newestLog) or die "can't open $newestLog: $!";
	}
	while (<LOGFILE>) 
	{ 
		restartPBS($_) if ($_ =~ /job allocation request exceeds currently available cluster nodes/) 
	} 
    	sleep 30;
	LOGFILE->clearerr( ) if($newestLog eq getLatestLog());            # clear stdio error flag
}

sub restartPBS
{
	return if (($throttle + 600) > time());
	$throttle = time();
	system("logger -t PBS_HUNG PBS TORQUE freeze detected automatically restarting  torque_server"); 
	print STDERR "PBS_HUNG PBS TORQUE freeze detected automatically restarting torque_server\n";
	#system("systemctl restart torque_sched.service");
	sleep 5;
	#system("systemctl restart torque_server.service");
}

sub getLatestLog
{
	my @list = `ls -t /cm/shared/apps/torque/var/spool/server_logs`;
	return "/cm/shared/apps/torque/var/spool/server_logs/" . $list[0];
}

