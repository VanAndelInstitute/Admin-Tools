#!/bin/bash
cd  /primary/instruments/sequencing/illumina/incoming/
mkdir -p .trash
find 1* -maxdepth 0 -mtime +90 -type d -exec mv {} .trash \; 
chown -R marie.adams .trash
