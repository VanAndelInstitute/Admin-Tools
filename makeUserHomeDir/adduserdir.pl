#!/usr/bin/perl
#
$username = $ARGV[0];
runcmd("cp -a /etc/skel /primary/home/$username");
runcmd("chown -R $username\.users /primary/home/$username");
sub runcmd{
	my $cmd=shift @_;
	my $caller=(caller(1))[3];
	print STDERR "$caller\t$cmd\n";
	system($cmd);
}
