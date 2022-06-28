#!/usr/bin/perl
$if = $ARGV[0] || die "specify a network interface";
$sleep = $ARGV[1] || 10;

$rx = "ifconfig $if | grep RX | grep pack";
$tx = "ifconfig $if | grep TX |grep pack";

print STDERR "watching $if for $sleep seconds...\n";

while (1)
{
	my $rx1 = &getBytes(`$rx`);
	my $tx1 = &getBytes(`$tx`);
	sleep $sleep;
	my $rx2 = &getBytes(`$rx`);
	my $tx2 = &getBytes(`$tx`);
	my $date = `date`;
	chomp $date;
	print "$date\t";
	print "RX: " . (($rx2 - $rx1)/$sleep/1000000) . "\tMBs\t\t";
	print "TX: " . (($tx2 - $tx1)/$sleep/1000000) . "\tMBs\n";

}



sub getBytes
{
	my $s = shift @_;
	$s =~ /bytes\s+(\d+)\s+/;
	return $1;
}
