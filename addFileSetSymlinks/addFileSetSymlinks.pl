#!/usr/bin/perl

$user = shift @ARGV || die "usage: addFileSetSymlinks.pl username fileset-name\nex: addFileSetSymlinks.pl zack.ramjan laird\n";
$fileset = shift @ARGV || die "usage: addFileSetSymlinks.pl username fileset-name\nex: addFileSetSymlinks.pl zack.ramjan laird\n";


die "/home/$user does not exist\n" unless -d "/home/$user";
die "/primary/projects/$fileset does not exist\n" unless -d "/primary/projects/$fileset";
die "/secondary/projects/$fileset does not exist\n" unless -d "/secondary/projects/$fileset";
die "/secondary/projects/$fileset does not exist\n" unless -d "/secondary/projects/$fileset";
die "/home/$user/$fileset-primary already is created\n" if -e "/home/$user/$fileset-primary";
die "/home/$user/$fileset-secondary already is created\n" if -e "/home/$user/$fileset-secondary";

system "su - $user -c \"ln -s /primary/projects/$fileset /home/$user/$fileset-primary\"";
system "su - $user -c \"ln -s /secondary/projects/$fileset /home/$user/$fileset-secondary\"";
