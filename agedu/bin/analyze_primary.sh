#!/bin/bash

cd /primary/vari/admin/tools/agedu/index_files/primary
/primary/vari/admin/tools/agedu/bin/agedu --mtime --prune .snapshots -r 1y -s /primary
