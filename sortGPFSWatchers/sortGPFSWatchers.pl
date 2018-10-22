#!/usr/bin/perl
use Net::SMTP;

$alarmMaxCount = 10;
$alarmCutoff = 10;
$alarmHits = 0;
@output = `mmlsnode -N waiters -L`;
for (@output)
{
	$_ =~ /(\d*\.?\d*) sec/;
	$hash{$_} = $1;
	$alarmHits++ if $1 > $alarmCutoff;
}

foreach my $name (sort { $hash{$a} <=> $hash{$b} } keys %hash) {
    print "$hash{$name} $name" if $ARGV[0];
}

exit if $ARGV[0];
system("logger GPFS_WAITERS: Number is GPFS Waiters is high: $alarmHits waiters over $alarmCutoff sec") if $alarmHits >= $alarmMaxCount;
sendmail("GPFS_WAITERS: Number is GPFS Waiters is high: $alarmHits waiters over $alarmCutoff sec","GPFS_WAITERS: Number is GPFS Waiteres is high: $alarmHits waiters over $alarmCutoff sec") if $alarmHits >= $alarmMaxCount;

sub sendmail
{
        #my $to = "hpcadmins\@vai.org";
        my $to = "zack.ramjan\@vai.org";
        my $from = "gpfs1a\@vai.org";
        my $subject = $_[0];
        my $message = $_[1];
        my $smtp = Net::SMTP->new('smtp.vai.org');
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
        system("logger gpfs error: $subject");
}
