#/bin/bash

# pull the total amount of system memory from meminfo
TOTAL_MEM=`/usr/bin/awk '/MemTotal/ {a=$2} END{printf("%d", a)}' /proc/meminfo`

# optionally allow the percentage to be changed on the command line, default to 25% of TOTAL_MEM 
PERCENTAGE_ALLOWED=$1
[ -z "$PERCENTAGE_ALLOWED" ] && PERCENTAGE_ALLOWED=4

# set the maximum allowed memory for a user process
MAX_ALLOWED_MEM=$((TOTAL_MEM / PERCENTAGE_ALLOWED))

function process_ps(){
  while read -r line; do

    # separate each line by whitespace and assign variables
    arr=($line)
    user=${arr[0]}
    uid=${arr[1]}
    pid=${arr[2]}
    fname=${arr[3]}
    size=${arr[4]}

    # if the the process is using more memory than allowed and user is not a system user, alert the user and send to graylog
    if [ "$size" -ge "$MAX_ALLOWED_MEM" ] && [ "$uid" -gt 500 ]; then
      #`echo "Your process, $fname ($pid), appears to be consuming more than the maximum memory allowed for a user process on the head node. An alert has been sent to the HPC Admins." | write $user`
      /usr/bin/logger "Process $fname ($pid) owned by $user is using more than the maximum memory allowed on the head node."
    fi
  done <<< "$(/usr/bin/ps -eo user:35,uid,pid,fname,size --sort size | /usr/bin/tail)"
}

process_ps
