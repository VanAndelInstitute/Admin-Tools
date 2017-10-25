#!/bin/bash

##############################################################
#  
#  Author     : Matthew Hoffman
#  Company    : Van Andel Institute
#  Description: 
#  Find nodes that are down or offline without logging the
#  output. Used for manual testing
#
##############################################################

function report_offline_nodes {
  offline_nodes=( $(pbsnodes | grep -B 1 'offline' | grep node) )
  down_nodes=( $(pbsnodes | grep -i -B 1 'down' | grep node) )
  for (( i=0; i<${#offline_nodes[@]}; i++ )); do echo "${offline_nodes[i]} is offline" ; done
  for (( i=0; i<${#down_nodes[@]}; i++ )); do echo "${down_nodes[i]} is down" ; done
}

report_offline_nodes
