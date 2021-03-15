#!/bin/bash
cd /primary/vari/admin/tools/agedu/index_files/secondary
/primary/vari/admin/tools/agedu/bin/agedu --prune .snapshots --mtime -r 1y -s /secondary
