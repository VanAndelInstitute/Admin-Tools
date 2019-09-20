#!/bin/bash
cd  /primary/instruments/iscan/
mkdir -p .trash
find *_20* -maxdepth 0 -mtime +60 -type d -exec mv {} .trash \;
chown -R marie.adams .trash
