#!/bin/bash

########################################
#                                      #
#  This script will find and copy all  #
#  files that have not been accessed   #
#  within the last 365 days to an      #
#  Archive directory.                  #
#  Their directory structure is main-  #
#  tained.                             #
#                                      #
#  Written by Kenneth Mendenhall       #
#  June 2026                           #
#                                      #
########################################

workDir=/varidata/research/projects/mind_hci
fileList=$(date +%Y-%m-%d)_filelist.txt

if [ ! -e $workDir/.Archive ]; then
    mkdir -p $workDir/.Archive
fi

cd $workDir 

if [ ! -e $workDir/.Archive/$fileList ]; then
	echo "finding files..."
	find . -type f -path './.Archive' -prune -o -ctime +365 -print > $workDir/.Archive/$fileList  #list the individual files.
fi
#Need to move all directories below mind_hci
echo "moving files..."
rsync -avvxlr --remove-source-files --files-from=$workDir/.Archive/$fileList ./ ./.Archive/
#rsync -avvxlr --files-from=$workDir/.Archive/$fileList ./ ./.Archive/

#chown -R erin.williams: /varidata/research/projects/mind_hci/.Archive/

#echo "" | mail -s "Mind_HCI data has been moved to .Archive folder successfully" erin.williams@vai.org


