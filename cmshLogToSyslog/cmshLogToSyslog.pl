#!/usr/bin/perl
use Date::Parse;
system "touch /tmp/zzz";
my $now = time;


my @hits = `/cm/local/apps/cmd/bin/cmsh -c \"events 100\"`;
chomp @hits;

for my $h (@hits)
{
	next unless $h =~ /\d\d:\d\d/;
	my @d = split /\s\[/, $h;
	my $logAge = $now - str2time($d[0]);
	system("logger -t CMSH \"$h\"") if $logAge < 3601;
}
