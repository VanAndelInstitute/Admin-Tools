#!/bin/bash
cd  /primary/instruments/sequencing/illumina/incoming/
mkdir -p .trash
find 1* -maxdepth 0 -mtime +60 -type d -exec mv {} .trash \; 
find 2* -maxdepth 0 -mtime +60 -type d -exec mv {} .trash \; 
chown -R marie.adams .trash
