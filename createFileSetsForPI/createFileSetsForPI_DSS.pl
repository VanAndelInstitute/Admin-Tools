#!/usr/bin/perl
use strict;

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  Create filesets for a new investigator on primary and varidata/research
#  
#
##############################################################

my $CR = "/usr/lpp/mmfs/bin/mmcrfileset";
my $LINK = "/usr/lpp/mmfs/bin/mmlinkfileset";
my $LS = "/usr/lpp/mmfs/bin/mmlsfileset";
my $LSQ = "/usr/lpp/mmfs/bin/mmlsquota";
my $ED = "/usr/lpp/mmfs/bin/mmedquota";
my $SQ = "/usr/lpp/mmfs/bin/mmsetquota";
 
my $pi = shift @ARGV;
die unless $pi;


my $doACL = shift @ARGV;

die if -e "/varidata/research/projects/$pi";

runcmd("$CR research $pi --inode-space projects");

runcmd("$LINK research $pi -J /varidata/research/projects/$pi");

## runcmd("$ED -j research:$pi");

##############################################################
## mmsetquota research:lempradl --block 10T:10T
##############################################################
exit if $doACL;
runcmd("$SQ research:$pi --block 40T:40T");

runcmd("$LSQ -j $pi research --block-size=auto");

runcmd("chgrp $pi\.lab-modify /varidata/research/projects/$pi");

runcmd("chmod g+rwx /varidata/research/projects/$pi");

runcmd("setfacl -m g:'domain users':--- /varidata/research/projects/$pi");

runcmd("setfacl -m g:$pi\.lab-full:rwx /varidata/research/projects/$pi");
runcmd("setfacl -m g:$pi\.lab-modify:rwx /varidata/research/projects/$pi");
runcmd("setfacl -m g:fs_admins:rwx /varidata/research/projects/$pi");

runcmd("setfacl -m d:g:$pi\.lab-full:rwx /varidata/research/projects/$pi");
runcmd("setfacl -m d:g:$pi\.lab-modify:rwx /varidata/research/projects/$pi");
runcmd("setfacl -m d:g:fs_admins:rwx /varidata/research/projects/$pi");
runcmd("setfacl -m d:g:'domain users':--- /varidata/research/projects/$pi");

## runcmd("setfacl -m g:$pi\.lab-read:rx /varidata/research/projects/$pi");
runcmd("setfacl -m g:fs_read:rx /varidata/research/projects/$pi");
runcmd("setfacl -m d:g:fs_read:rx /varidata/research/projects/$pi");


runcmd("$LS research");

sub runcmd{
        my $cmd=shift @_;
        my $caller=(caller(1))[3];
        print STDERR "$caller\t$cmd\n";
        system($cmd);
}

