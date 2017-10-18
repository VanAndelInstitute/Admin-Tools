#!/bin/bash
cd  /primary/instruments/iscan/
mkdir -p .trash
find 20* -maxdepth 0 -mtime +90 -type d -exec mv {} .trash \;
chown -R marie.adams .trash
