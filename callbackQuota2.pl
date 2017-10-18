#!/usr/bin/perl
use Net::SMTP;
use Data::Dumper;
use strict;


my @params = ('blockLimit', 'blockQuota', 'blockUsage', 'filesetName', 'filesetSize', 'fsName', 'quotaID', 'quotaOwnerName', 'quotaType');

my %value;
$value{$params[$_]} = $ARGV[$_] for (0..$#ARGV);
my $msg_body .= "$_ $value{$_}\n" for keys(%value);

getPathForFileSet();
#sendmail("Soft Quota has been exceeded", $msg_body);

sub sendmail
{
	my ($name,$group) = getOwner();
        my $to = "jason.kotecki\@vai.org";
        my $from = "gpfs1a\@vai.org";
        my $subject = $_[0];
        my $message = $_[1];
        my $smtp = Net::SMTP->new('10.152.11.74');
        $smtp->mail($from);
        if ($smtp->to($to)) {
             $smtp->data();
             $smtp->datasend("To: $to\n");
             $smtp->datasend("Subject: $subject\n");
             $smtp->datasend("\n");
             $smtp->datasend("$subject\n$message\n");
             $smtp->dataend();
            } else {
             print "Error: ", $smtp->message();
            }
            $smtp->quit;
}

sub getOwner
{
	my @filesetOutput = `mmlsfileset $value{"fsName"} $value{"filesetName"}`;
	my @path = split(/\s+/,@filesetOutput[2]);
	my $uid = (stat $path[2])[4];
	my $gid = (stat $path[2])[5];
	my $name = `ssh login01 getent passwd $uid`;
	my $group = `ssh login01 getent group $gid`;
	$name=~ s/\:.+$//;
	$group=~ s/\:.+$//;
	chomp $name, $group;	
	return ($name,$group);
}
