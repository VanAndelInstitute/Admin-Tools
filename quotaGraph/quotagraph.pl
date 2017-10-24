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

$out = `for i in \`$gpfs/mmlsfileset  home | cut -f 1 -d ' ' | tail -n +3 | sort | xargs \`; do echo \$i \`$gpfs/mmlsquota -j \$i home   | tail -n 1 | sed 's/|.\+//g' \` ; done ; for i in \`$gpfs/mmlsfileset  scratch | cut -f 1 -d ' ' | tail -n +3 | sort | xargs \`; do echo \$i \`$gpfs/mmlsquota -j \$i scratch  | tail -n 1 | sed 's/|.\+//g' \` ; done `;

open OUT, ">$outfile";
print OUT $out;

