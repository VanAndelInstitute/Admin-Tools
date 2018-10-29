#!/usr/bin/perl


system("bash -l -c /primary/vari/admin/tools/pbsnodezParsable/pbsnodezParsable > /var/www/html/pbsnodezTxt.txt.new");
system("bash -l -c \"qstat -a | tail -n +6\" > /var/www/html/qstat.txt.new");
system("cp /primary/vari/admin/gpfs-tools/quotaGraph/quotatable.txt /var/www/html/quotatable.txt");

checkAndReplace("/var/www/html/pbsnodezTxt.txt.new","/var/www/html/pbsnodezTxt.txt");
checkAndReplace("/var/www/html/qstat.txt.new","/var/www/html/qstat.txt");

sub checkAndReplace()
{
  my $src = shift @_;
  my $dst = shift @_;
  if (-s $src > 2000)
  { 
    system("mv $src $dst")
  }
}
