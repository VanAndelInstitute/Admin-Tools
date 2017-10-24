#!/usr/bin/perl
use File::stat;

##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  for each group's fileset, create a cores writable folder for depositing data
#  also make sure to prevent core users from seeing other data not belonging to them
#
##############################################################


$COREDIR = "vari-core-generated-data";
for my $d (glob("/primary/projects/*"))
{
	next unless $d =~ /\/chandler/;
	next if $d =~ /core/;
	next if $d =~ /bbc/;
	next if $d =~ /synology/;
	next if $d =~ /VADR/;
	next if $d =~ /vivarium/;
	next unless -d $d;
	print STDERR "processing $d\n";
	my $group = getgrgid(stat($d)->gid);
	next if $group =~ /root/;
	chdir("$d/$COREDIR");
	runcmd("setfacl -m g:cores-full:rx $d");
	runcmd("mkdir $d/$COREDIR");	
	runcmd("chown root:cores-full  $d/$COREDIR");	
	runcmd("setfacl -m g:cores-full:rwx  $d/$COREDIR");	
	runcmd("setfacl -m d:g::000  $d");	
	runcmd("setfacl -m d:g:\'domain users\':000  $d");	
	runcmd("setfacl -m d:g:" . $group . ":rwx $d");
	my @files = glob("$d/*");
	for my $f (@files)
	{
		next unless getgrgid(stat($f)->gid) =~ /domain users/;
		next if $f =~ /^\./;
		next if $f =~ /$COREDIR/;
		runcmd("setfacl -m g::000  $f");	
		runcmd("setfacl -m g:\'domain users\':000  $f");	
		runcmd("setfacl -m g:" . $group . ":rwx $f");
	}
	print STDERR "\n";
}

sub runcmd{
        my $cmd=shift @_;
        my $caller=(caller(1))[3];
        print STDERR "$caller\t$cmd\n";
        #system($cmd);
}
