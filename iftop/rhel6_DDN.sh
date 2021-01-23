#!/usr/bin/perl

my $ip = `ip a |grep 220`;
$ip =~ /(10\.152\.220\.\d+).+\s+(\w+)$/;
$ip = $1;
$iface = $2;




system "/primary/vari/admin/tools/iftop/rhel6/usr/sbin/iftop -B -i $iface";
