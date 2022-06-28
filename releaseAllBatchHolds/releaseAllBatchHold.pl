#!/usr/bin/env perl
#

$date = `date`;
chomp $date;

my @jobs = `/cm/shared/apps/moab/default/bin/mshow -x 2>&1 |grep BatchHold`;
chomp @jobs;

unless (@jobs)
{

  print STDERR "$date: No batchHold Jobs\n"; 
  exit;
}

for my $j (@jobs)
{
  print STDERR "$date: Releasing $j\n";
  my @jDetails = split /\s+/,$j;
  print STDERR "\tJob ID: $jDetails[0]\n";
  print STDERR "\tmjobctl -u $jDetails[0]\n";
  system "/cm/shared/apps/moab/default/bin/mjobctl -u $jDetails[0]";

}
sleep 30;
print STDERR "$date: restarting moab";
system("systemctl restart moab");
