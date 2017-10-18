#!/usr/bin/perl



$root = "/primary/vari/software";



@tools = glob("$root/*");

@tools = grep { -d $_ } @tools;


for my $d (@tools)
{
	my $dir = $d;
	$dir = "$d/default" if -e "$d/default";
	$dir = "$d/default/bin" if -e "$d/default/bin";
	$dir =~ s/$root/\$root/;
	print "prepend-path      PATH              $dir\n";            
}
