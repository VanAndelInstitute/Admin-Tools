#!/bin/bash

##############################################################
#  
#  Author     : Matthew Hoffman
#  Company    : Van Andel Institute
#  Description: 
#  Detect and log when nodes go down or become offline.
#
##############################################################

function report_offline_nodes {
  offline_nodes=( $(/cm/shared/apps/torque/current/bin/pbsnodes | grep -B 1 'offline' | grep node) )
  down_nodes=( $(/cm/shared/apps/torque/current/bin/pbsnodes | grep -i -B 1 'down' | grep node) )
  for (( i=0; i<${#offline_nodes[@]}; i++ )); do logger "${offline_nodes[i]} is offline" ; done
  for (( i=0; i<${#down_nodes[@]}; i++ )); do logger "${down_nodes[i]} is down" ; done
}

report_offline_nodes
