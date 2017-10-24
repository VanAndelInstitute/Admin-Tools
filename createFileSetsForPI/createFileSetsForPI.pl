#!/usr/bin/perl
use strict;

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  Create filesets for a new investigator on primary and secondary
#  
#
##############################################################

my $CR = "/usr/lpp/mmfs/bin/mmcrfileset";
my $LINK = "/usr/lpp/mmfs/bin/mmlinkfileset";
my $LS = "/usr/lpp/mmfs/bin/mmlsfileset";
my $LSQ = "/usr/lpp/mmfs/bin/mmlsquota";
my $ED = "/usr/lpp/mmfs/bin/mmedquota";
 
my $pi = shift @ARGV;
die unless $pi;

die if -e "/primary/projects/$pi";
die if -e "/secondary/projects/$pi";

runcmd("$CR home $pi");
runcmd("$CR scratch $pi");

runcmd("$LINK home $pi -J /primary/projects/$pi");
runcmd("$LINK scratch $pi -J /secondary/projects/$pi");

runcmd("$LS home");
runcmd("$LS scratch");

runcmd("$ED -j home:$pi");
runcmd("$ED -j scratch:$pi");

runcmd("$LSQ -j $pi home --block-size=auto");
runcmd("$LSQ -j $pi scratch --block-size=auto");

runcmd("chgrp $pi\.lab-modify /primary/projects/$pi");
runcmd("chgrp $pi\.lab-modify /secondary/projects/$pi");

runcmd("chmod g+rwx /primary/projects/$pi");
runcmd("chmod g+rwx /secondary/projects/$pi");

runcmd("setfacl -m g:$pi\.lab-full:rwx /primary/projects/$pi");
runcmd("setfacl -m g:$pi\.lab-full:rwx /secondary/projects/$pi");
runcmd("setfacl -m g:$pi\.lab-modify:rwx /primary/projects/$pi");
runcmd("setfacl -m g:$pi\.lab-modify:rwx /secondary/projects/$pi");
runcmd("setfacl -m g:fs_admins:rwx /secondary/projects/$pi");
runcmd("setfacl -m g:fs_admins:rwx /primary/projects/$pi");

runcmd("setfacl -m g:$pi\.lab-read:rx /primary/projects/$pi");
runcmd("setfacl -m g:$pi\.lab-read:rx /secondary/projects/$pi");
runcmd("setfacl -m g:fs_read:rx /secondary/projects/$pi");
runcmd("setfacl -m g:fs_read:rx /primary/projects/$pi");



sub runcmd{
        my $cmd=shift @_;
        my $caller=(caller(1))[3];
        print STDERR "$caller\t$cmd\n";
        system($cmd);
}

