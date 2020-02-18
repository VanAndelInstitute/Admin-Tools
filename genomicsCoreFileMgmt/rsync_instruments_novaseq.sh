#!/bin/bash
cd  /primary/instruments/sequencing/novaseq/
mkdir -p .trash
find 2* -maxdepth 0 -mtime +60 -type d -exec mv {} .trash \; 
chown -R marie.adams .trash
