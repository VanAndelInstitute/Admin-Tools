#!/bin/bash

# Verify the user is part of a group with the right privileges
check_group(){
  
  # if OK=0, the user can restart the node. Begin by assuming they cannot
  OK=1 
  
  # hpcadmins can restart any node
  if id -nG "$SUDO_USER" | grep -qw "hpcadmins"; then OK=0;
  
  # li users can restart any node between 61 and 63 inclusive
  elif id -nG "$SUDO_USER" | grep -qw "hli.lab-modify"; then
    if [ "$NODE" -ge 61 -a "$NODE" -le 63 ]; then OK=0; fi

  # bio users can restart any node between 65 and 68 inclusive and 201 and 203 inclusive
  elif id -nG "$SUDO_USER" | grep -qw "bioinformatics-modify"; then 
    if [ "$NODE" -ge 65 -a "$NODE" -le 68 ]; then OK=0;
    elif [ "$NODE" -ge 201 -a "$NODE" -le 203 ]; then OK=0; fi

  # if none of the previous patterns match, user cannot restart the node, exit
  else											
    echo $SUDO_USER cannot restart that node... Exiting
    exit 0				
  fi
}

# Use the Bright cmsh to reset the node via IPMI
reset_node(){
   cmsh -c "device power -n node$NODE reset" 
}

# Have the user confirm that they wish to restart the node requested
verify_input(){
  printf "Restart node$NODE? (y|n) :"
  read input
  if [[ "$input" != "y" ]]; then
    exit 0
  fi
}

# ensure that there is one and only one node provided as an argument
if [ $# -ne 1 ]
then
  printf "Invalid number of arguments.\nUsage: sudo ./restart_node.sh <node_num>\n"
  exit 0
fi

# set the node, accept either the node number, 065, or the full node name, node065
NODE=$(echo "$1" | egrep -o [0-9]+)

# if and only if the user can restart the node, do so
check_group
if [ "$OK" -eq 0 ]; then
  verify_input
  echo Restarting node$NODE
  reset_node
fi

exit 0
