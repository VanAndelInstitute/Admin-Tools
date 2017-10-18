#!/usr/bin/perl
use Net::SMTP;

my @params = ('blockLimit', 'blockQuota', 'blockUsage', 'filesetName', 'filesetSize', 'fsName', 'quotaID', 'quotaOwnerName', 'quotaType');
foreach $argnum (0 .. $#ARGV) {
    push(@msg_body,"$params[$argnum]: $ARGV[$argnum]\n");
}
my $body = join("\n",@msg_body),"\n";
sendmail("Soft Quota has been exceeded", $body);
done;

sub sendmail
{
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
