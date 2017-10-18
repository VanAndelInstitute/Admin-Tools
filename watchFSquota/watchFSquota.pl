#!/usr/bin/perl
use Net::SMTP;
my @filesets =`for i in \`/usr/lpp/mmfs/bin/mmlsfileset  home | cut -f 1 -d ' ' | tail -n +3 | sort | xargs \`; do echo \$i \`/usr/lpp/mmfs/bin/mmlsquota -j \$i home --block-size auto  | tail -n 1 | sed 's/|.\+//g' \` ; done ; for i in \`/usr/lpp/mmfs/bin/mmlsfileset  scratch | cut -f 1 -d ' ' | tail -n +3 | sort | xargs \`; do echo \$i \`/usr/lpp/mmfs/bin/mmlsquota -j \$i scratch --block-size auto  | tail -n 1 | sed 's/|.\+//g' \` ; done`;

my @msgFS;
my @projectFS;
for my $line (@filesets)
{
	my @e = split /\s+/, $line;
	if($e[7] && $e[7] ne "none")
	{
		push @msgFS, $line; 				
		push @projectFS, "$e[0]:$e[1]"; 				
	}
}

sendmail(join(", ", @projectFS) . " triggered quota warning" ,join("", @msgFS)) if @projectFS;



################################

sub sendmail
{
	my $to = "hpcadmins\@vai.org";
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
