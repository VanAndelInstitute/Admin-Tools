#!/bin/bash
##############################################################
#  
#  Author     : zack ramjan
#  Company    : Van Andel Institute
#  Description: 
#  dont allow mmfs processes to get killed if we run out of ram.
#
##############################################################
pgrep "mmfs" | while read PID; do echo -17 > /proc/$PID/oom_adj; done

