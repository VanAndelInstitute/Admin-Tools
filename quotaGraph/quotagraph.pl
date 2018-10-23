#!/usr/bin/perl
##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
# 
#  print out the quota usage for each group's filesets
#
##############################################################



$outfile = "/primary/vari/admin/tools/quotaGraph/quotatable.txt";
$gpfs = "/usr/lpp/mmfs/bin";

$out = `$gpfs/mmrepquota -j home | tail -n +4 | sed 's/root\\s*FILESET/home FILESET/' | sed 's/\\s\\s*/ /g'`;
$out .=`$gpfs/mmrepquota -j scratch | tail -n +4 | sed 's/root\\s*FILESET/scratch FILESET/' | sed 's/\\s\\s*/ /g'`;

open OUT, ">$outfile";
print OUT $out;

