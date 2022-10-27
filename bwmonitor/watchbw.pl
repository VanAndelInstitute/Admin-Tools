#!/usr/bin/perl
$sleep = $ARGV[0] || 3;
$if = $ARGV[1] ;


print STDERR "watching $if for $sleep seconds...\n";

while (1)
{
	my $rx1 = 0;	
	my $tx1 = 0;	
	my $rx2 = 0;	
	my $tx2 = 0;	

	@rx = `ifconfig $if | grep RX | grep pack`;
	@tx = `ifconfig $if | grep TX |grep pack`;

	$rx1 += &getBytes($_) for @rx;
	$tx1 += &getBytes($_) for @tx;
	sleep $sleep;

	@rx = `ifconfig $if | grep RX | grep pack`;
	@tx = `ifconfig $if | grep TX |grep pack`;
	$rx2 += &getBytes($_) for @rx;
	$tx2 += &getBytes($_) for @tx;
	my $date = `date`;
	chomp $date;
	print "$date\t\t\t";
	print "RX: " . int(($rx2 - $rx1)/$sleep/1000000) . " MBs\t";
	print "TX: " . int(($tx2 - $tx1)/$sleep/1000000) . " MBs\n";

}



sub getBytes
{
	my $s = shift @_;
	#	print STDERR "-> $s\n";
	$s =~ /bytes\s+(\d+)\s+/;
	return int($1);
}
